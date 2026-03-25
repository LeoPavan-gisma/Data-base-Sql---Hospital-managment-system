# Hospital Management System - API & Query Guide
# M605 Advanced Databases - Complete Query Reference

## SQL Query Examples

### 1. PATIENT MANAGEMENT QUERIES

#### Query: Get Complete Patient Profile with Statistics
```sql
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.DateOfBirth,
    YEAR(CURDATE()) - YEAR(p.DateOfBirth) - 
    (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(p.DateOfBirth, '%m%d')) AS Age,
    p.Gender,
    p.BloodType,
    p.Email,
    p.Phone,
    p.InsuranceProvider,
    p.PolicyNumber,
    p.PreexistingConditions,
    p.Allergies,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT lr.LabResultID) AS LabTestsPerformed,
    COUNT(DISTINCT mr.MedicalRecordID) AS MedicalRecordCount
FROM Patients p
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
WHERE p.PatientID = ?
GROUP BY p.PatientID;
```

**Purpose:** Get comprehensive patient overview
**Use Case:** Patient dashboard, medical history review
**Performance:** <1ms with proper indexing

---

#### Query: Search Patients by Multiple Criteria
```sql
SELECT p.PatientID, CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
       p.Email, p.Phone, p.BloodType, p.InsuranceProvider,
       COUNT(DISTINCT a.AppointmentID) AS AppointmentCount
FROM Patients p
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
WHERE (p.FirstName LIKE CONCAT('%', ?, '%') OR p.LastName LIKE CONCAT('%', ?, '%'))
  AND (? IS NULL OR p.BloodType = ?)
  AND (? IS NULL OR p.InsuranceProvider = ?)
  AND p.DateOfBirth BETWEEN ? AND ?
GROUP BY p.PatientID
ORDER BY p.LastName, p.FirstName;
```

**Purpose:** Advanced patient search with multiple filters
**Parameters:** firstName, lastName, bloodType, bloodType, insuranceProvider, insuranceProvider, minDOB, maxDOB
**Use Case:** Patient lookup, batch processing

---

### 2. APPOINTMENT MANAGEMENT QUERIES

#### Query: Get Doctor's Daily Schedule
```sql
SELECT 
    a.AppointmentID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Email,
    p.Phone,
    a.AppointmentDate,
    a.AppointmentTime,
    a.ReasonForVisit,
    a.AppointmentStatus,
    CASE 
        WHEN a.AppointmentStatus = 'Completed' THEN 'blue'
        WHEN a.AppointmentStatus = 'No-Show' THEN 'red'
        WHEN a.AppointmentStatus = 'Cancelled' THEN 'gray'
        ELSE 'green' 
    END AS StatusColor
FROM Appointments a
INNER JOIN Patients p ON a.PatientID = p.PatientID
WHERE a.DoctorID = ?
  AND DATE(a.AppointmentDate) = ?
ORDER BY a.AppointmentTime;
```

**Use Case:** Doctor's daily schedule, appointment reminders
**Performance:** <10ms

---

#### Query: Find Appointment Conflicts
```sql
SELECT 
    a1.AppointmentID AS Appointment1,
    a2.AppointmentID AS Appointment2,
    a1.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    a1.AppointmentDate,
    a1.AppointmentTime AS Time1,
    a2.AppointmentTime AS Time2,
    CONCAT(p1.FirstName, ' ', p1.LastName) AS Patient1,
    CONCAT(p2.FirstName, ' ', p2.LastName) AS Patient2
FROM Appointments a1
INNER JOIN Appointments a2 ON a1.DoctorID = a2.DoctorID
INNER JOIN Doctors d ON a1.DoctorID = d.DoctorID
INNER JOIN Patients p1 ON a1.PatientID = p1.PatientID
INNER JOIN Patients p2 ON a2.PatientID = p2.PatientID
WHERE a1.AppointmentID < a2.AppointmentID
  AND DATE(a1.AppointmentDate) = DATE(a2.AppointmentDate)
  AND a1.AppointmentStatus NOT IN ('Cancelled', 'No-Show')
  AND a2.AppointmentStatus NOT IN ('Cancelled', 'No-Show')
  AND ABS(TIMEDIFF(a1.AppointmentTime, a2.AppointmentTime)) < '00:30:00';
```

**Purpose:** Detect scheduling conflicts
**Use Case:** Appointment validation before booking

---

### 3. LABORATORY RESULTS QUERIES

#### Query: Alert for Critical Lab Values
```sql
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Email,
    p.Phone,
    lt.LabTestName,
    lr.TestResult,
    lt.NormalRange,
    lr.TestDate,
    CONCAT(d.FirstName, ' ', d.LastName) AS OrderedBy,
    'CRITICAL - IMMEDIATE ACTION REQUIRED' AS AlertLevel
FROM LabResults lr
INNER JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
INNER JOIN Patients p ON lr.PatientID = p.PatientID
INNER JOIN Doctors d ON lr.DoctorID = d.DoctorID
WHERE lr.IsCritical = 1
  AND lr.TestDate >= DATE_SUB(CURDATE(), INTERVAL 24 HOUR)
ORDER BY lr.TestDate DESC;
```

**Purpose:** Generate critical value alerts
**Use Case:** Real-time monitoring, patient safety

---

#### Query: Lab Test Abnormality Trends
```sql
SELECT 
    lt.LabTestName,
    COUNT(*) AS TotalTests,
    SUM(CASE WHEN lr.IsNormal = 0 THEN 1 ELSE 0 END) AS AbnormalCount,
    SUM(CASE WHEN lr.IsCritical = 1 THEN 1 ELSE 0 END) AS CriticalCount,
    ROUND(SUM(CASE WHEN lr.IsNormal = 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS AbnormalityRate,
    ROUND(AVG(CAST(EXTRACT(DAY FROM lr.TestDate) AS DECIMAL)), 1) AS AvgTestsPerDay
FROM LabResults lr
INNER JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
WHERE lr.TestDate >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY lt.LabTestID, lt.LabTestName
HAVING TotalTests >= 5
ORDER BY AbnormalityRate DESC;
```

**Purpose:** Analyze lab test patterns and abnormality rates
**Use Case:** Quality assurance, disease pattern analysis

---

### 4. CLINICAL RECORDS QUERIES

#### Query: Complete Treatment Timeline for Patient
```sql
SELECT 
    a.AppointmentID,
    a.AppointmentDate,
    a.ReasonForVisit,
    a.AppointmentStatus,
    mr.Diagnosis,
    mr.Symptoms,
    mr.TreatmentPlan,
    GROUP_CONCAT(DISTINCT lg.LabTestName) AS LabsOrdered,
    GROUP_CONCAT(DISTINCT m.MedicationName) AS PrescribedMeds,
    CONCAT(d.FirstName, ' ', d.LastName) AS Doctor
FROM Appointments a
LEFT JOIN MedicalRecords mr ON a.AppointmentID = mr.AppointmentID
LEFT JOIN LabResults lr ON a.PatientID = lr.PatientID 
    AND lr.TestDate BETWEEN a.AppointmentDate AND DATE_ADD(a.AppointmentDate, INTERVAL 7 DAY)
LEFT JOIN LabTests lg ON lr.LabTestID = lg.LabTestID
LEFT JOIN Prescriptions pr ON mr.PatientID = pr.PatientID
    AND pr.StartDate >= a.AppointmentDate
    AND pr.StartDate <= DATE_ADD(a.AppointmentDate, INTERVAL 7 DAY)
LEFT JOIN Medications m ON pr.MedicationID = m.MedicationID
LEFT JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.PatientID = ?
ORDER BY a.AppointmentDate DESC;
```

**Purpose:** Get complete clinical journey for patient
**Use Case:** Treatment review, continuity of care

---

### 5. PRESCRIPTION MANAGEMENT QUERIES

#### Query: Medication Contraindications Check
```sql
SELECT DISTINCT
    p.PrescriptionID,
    CONCAT(pat.FirstName, ' ', pat.LastName) AS PatientName,
    m1.MedicationName AS Medication1,
    m2.MedicationName AS Medication2,
    'CONTRAINDICATION' AS AlertType,
    p.Dosage,
    p.Frequency
FROM Prescriptions p
INNER JOIN Prescriptions p2 ON p.PatientID = p2.PatientID
INNER JOIN Medications m1 ON p.MedicationID = m1.MedicationID
INNER JOIN Medications m2 ON p2.MedicationID = m2.MedicationID
INNER JOIN Patients pat ON p.PatientID = pat.PatientID
WHERE p.PrescriptionID < p2.PrescriptionID
  AND p.EndDate >= CURDATE()
  AND p2.EndDate >= CURDATE()
  AND (m1.Contraindications LIKE CONCAT('%', m2.MedicationName, '%')
       OR m2.Contraindications LIKE CONCAT('%', m1.MedicationName, '%'));
```

**Purpose:** Detect dangerous drug interactions
**Use Case:** Prescription safety, clinical decision support

---

#### Query: Medication Refill Status
```sql
SELECT 
    pr.PrescriptionID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    m.MedicationName,
    pr.Dosage,
    pr.Frequency,
    pr.EndDate,
    pr.Refills,
    DATEDIFF(pr.EndDate, CURDATE()) AS DaysRemaining,
    CASE 
        WHEN DATEDIFF(pr.EndDate, CURDATE()) <= 0 THEN 'EXPIRED'
        WHEN DATEDIFF(pr.EndDate, CURDATE()) <= 7 THEN 'REFILL NEEDED'
        WHEN pr.Refills = 0 THEN 'NO REFILLS LEFT'
        ELSE 'ACTIVE'
    END AS RefillStatus
FROM Prescriptions pr
INNER JOIN Patients p ON pr.PatientID = p.PatientID
INNER JOIN Medications m ON pr.MedicationID = m.MedicationID
WHERE pr.EndDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
  AND pr.EndDate <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY DaysRemaining ASC;
```

**Purpose:** Track medication refills and expiration
**Use Case:** Pharmacy notifications, patient follow-up

---

### 6. FINANCIAL QUERIES

#### Query: Billing and Insurance Claims Summary
```sql
SELECT 
    b.BillingID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    b.Amount,
    b.InsuranceCoverage,
    (b.Amount - b.InsuranceCoverage) AS PatientResponsibility,
    b.PaymentStatus,
    b.PaymentDate,
    CASE 
        WHEN b.PaymentStatus = 'Paid' THEN 1
        WHEN b.PaymentStatus = 'Pending' THEN 2
        WHEN b.PaymentStatus = 'Overdue' THEN 3
    END AS PriorityOrder,
    DATEDIFF(CURDATE(), b.CreatedAt) AS DaysSinceBilling
FROM Billing b
INNER JOIN Patients p ON b.PatientID = p.PatientID
WHERE b.CreatedAt >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
  AND b.PaymentStatus IN ('Pending', 'Overdue')
ORDER BY PriorityOrder, DaysSinceBilling DESC;
```

**Purpose:** Track outstanding bills and insurance claims
**Use Case:** Collections, AR management

---

#### Query: Department Revenue Analysis
```sql
SELECT 
    dep.DepartmentName,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    SUM(b.Amount) AS TotalRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.Amount ELSE 0 END) AS PaidRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Pending' THEN b.Amount ELSE 0 END) AS PendingRevenue,
    SUM(CASE WHEN b.PaymentStatus = 'Overdue' THEN b.Amount ELSE 0 END) AS OverdueRevenue,
    ROUND(SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.Amount ELSE 0 END) / SUM(b.Amount) * 100, 2) AS CollectionRate,
    ROUND(AVG(b.Amount), 2) AS AvgBillAmount
FROM Billing b
INNER JOIN Appointments a ON b.AppointmentID = a.AppointmentID
INNER JOIN Departments dep ON b.DepartmentID = dep.DepartmentID
WHERE b.CreatedAt >= DATE_SUB(CURDATE(), INTERVAL 180 DAY)
GROUP BY dep.DepartmentID, dep.DepartmentName
ORDER BY TotalRevenue DESC;
```

**Purpose:** Revenue by department and payment status
**Use Case:** Financial reporting, performance analysis

---

### 7. ADVANCED ANALYTICS QUERIES

#### Query: Disease Pattern Analysis
```sql
SELECT 
    mr.Diagnosis,
    COUNT(DISTINCT mr.PatientID) AS PatientsAffected,
    YEAR(CURDATE()) - AVG(YEAR(p.DateOfBirth)) AS AveragePatientAge,
    GROUP_CONCAT(DISTINCT p.BloodType) AS AffectedBloodTypes,
    GROUP_CONCAT(DISTINCT m.MedicationName SEPARATOR ', ') AS CommonTreatments,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointmentsForDiagnosis,
    ROUND(COUNT(DISTINCT a.AppointmentID) / 
        (SELECT COUNT(DISTINCT AppointmentID) FROM Appointments) * 100, 2) AS AppointmentPercentage
FROM MedicalRecords mr
INNER JOIN Patients p ON mr.PatientID = p.PatientID
LEFT JOIN Appointments a ON mr.AppointmentID = a.AppointmentID
LEFT JOIN Prescriptions pr ON mr.PatientID = pr.PatientID
LEFT JOIN Medications m ON pr.MedicationID = m.MedicationID
WHERE mr.CreatedAt >= DATE_SUB(CURDATE(), INTERVAL 365 DAY)
GROUP BY mr.Diagnosis
HAVING PatientsAffected >= 2
ORDER BY PatientsAffected DESC;
```

**Purpose:** Identify disease patterns and treatment protocols
**Use Case:** Epidemiology, treatment effectiveness analysis

---

#### Query: Doctor Performance Metrics
```sql
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    SUM(CASE WHEN a.AppointmentStatus = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
    SUM(CASE WHEN a.AppointmentStatus = 'No-Show' THEN 1 ELSE 0 END) AS NoShowCount,
    ROUND(SUM(CASE WHEN a.AppointmentStatus = 'Completed' THEN 1 ELSE 0 END) / 
        COUNT(*) * 100, 2) AS CompletionRate,
    ROUND(SUM(CASE WHEN a.AppointmentStatus = 'No-Show' THEN 1 ELSE 0 END) / 
        COUNT(*) * 100, 2) AS NoShowRate,
    COUNT(DISTINCT mr.MedicalRecordID) AS CreatedRecords,
    AVG(CHAR_LENGTH(mr.ClinicalNotes)) AS AvgNotesLength,
    ROUND(AVG(cd.DaysToReview), 1) AS AvgDaysForFollowup
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID 
    AND a.AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 180 DAY)
LEFT JOIN MedicalRecords mr ON d.DoctorID = mr.DoctorID
LEFT JOIN (
    SELECT DoctorID, 
           AVG(DATEDIFF(a2.AppointmentDate, a1.AppointmentDate)) AS DaysToReview
    FROM Appointments a1
    LEFT JOIN Appointments a2 ON a1.PatientID = a2.PatientID 
        AND a2.AppointmentDate > a1.AppointmentDate
    WHERE a1.DoctorID IS NOT NULL
    GROUP BY a1.DoctorID
) cd ON d.DoctorID = cd.DoctorID
GROUP BY d.DoctorID
ORDER BY CompletionRate DESC;
```

**Purpose:** Evaluate doctor performance and productivity
**Use Case:** Performance reviews, resource allocation

---

## MongoDB Query Examples

### 1. Find Medical History by Patient
```javascript
db.MedicalHistory.find({ patientId: 1 }).pretty()
```

### 2. Get Recent Activity Logs
```javascript
db.ActivityLogs.find({
    timestamp: { $gte: new Date(ISODate().getTime() - 86400000) }
}).sort({ timestamp: -1 }).limit(50)
```

### 3. Find Critical Allergies
```javascript
db.AllergiesRegistry.find({
    severity: { $in: ["Severe", "Anaphylactic"] }
}).project({ patientId: 1, allergen: 1, severity: 1 })
```

### 4. Aggregation: Patient Communication Summary
```javascript
db.Communications.aggregate([
    { $match: { patientId: 1, isRead: false } },
    { $group: {
        _id: "$type",
        count: { $sum: 1 }
    }},
    { $sort: { count: -1 } }
])
```

### 5. Aggregation: Disease Patterns from Diagnostic Reports
```javascript
db.DiagnosticReports.aggregate([
    { $match: { reviewed: true } },
    { $group: {
        _id: "$reportType",
        totalReports: { $sum: 1 },
        avgQuality: { $avg: "$qualityScore" }
    }},
    { $sort: { totalReports: -1 } }
])
```

---

## Performance Optimization Tips

1. **Index Frequently Searched Fields:**
   - Patient email, phone
   - Appointment date, status
   - Lab result date, abnormality flag
   - Billing status, payment date

2. **Use Views for Common Reports:**
   - Patient profiles
   - Doctor schedules
   - Department workload
   - High-risk patients

3. **Archive Old Records:**
   ```sql
   -- Archive completed appointments >1 year old
   INSERT INTO AppointmentsArchive
   SELECT * FROM Appointments
   WHERE AppointmentStatus = 'Completed'
   AND AppointmentDate < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
   ```

4. **Monitor Query Performance:**
   ```sql
   EXPLAIN SELECT ... ; -- Shows query execution plan
   ```

---

**Last Updated:** March 2026  
**Version:** 1.0
