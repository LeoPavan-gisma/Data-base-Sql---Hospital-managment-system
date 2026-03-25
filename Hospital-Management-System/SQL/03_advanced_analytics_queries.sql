-- Hospital Management System - Advanced Analytical Queries
-- M605 Database Project - Analytics and Reporting

USE HospitalManagement;

-- ============================================================================
-- 1. PATIENT HEALTH ANALYSIS QUERIES
-- ============================================================================

-- Query 1: High-Risk Patients Report
SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.PatientID,
    p.DateOfBirth,
    YEAR(CURDATE()) - YEAR(p.DateOfBirth) AS Age,
    p.BloodType,
    GROUP_CONCAT(DISTINCT lr.Status) AS LabTestStatus,
    COUNT(DISTINCT lr.LabResultID) AS AbnormalTests,
    GROUP_CONCAT(DISTINCT CONCAT(lt.TestName, ': ', lr.TestValue, ' ', lt.Unit) SEPARATOR '; ') AS AbnormalResults
FROM Patients p
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID
LEFT JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
WHERE lr.Status IN ('Abnormal', 'Critical')
GROUP BY p.PatientID, p.FirstName, p.LastName, p.DateOfBirth, p.BloodType
HAVING COUNT(DISTINCT lr.LabResultID) > 1
ORDER BY COUNT(DISTINCT lr.LabResultID) DESC;

-- Query 2: Disease Pattern Analysis
SELECT 
    mr.Diagnosis,
    COUNT(*) AS PatientCount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT PatientID) FROM MedicalRecords), 2) AS PercentageOfPatients,
    GROUP_CONCAT(DISTINCT CONCAT(p.FirstName, ' ', p.LastName) SEPARATOR ', ') AS AffectedPatients
FROM MedicalRecords mr
JOIN Patients p ON mr.PatientID = p.PatientID
GROUP BY mr.Diagnosis
ORDER BY PatientCount DESC;

-- Query 3: Doctor Workload Analysis
SELECT 
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.DoctorID,
    d.Specialization,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Completed' THEN a.AppointmentID END) AS CompletedAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Scheduled' THEN a.AppointmentID END) AS ScheduledAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Cancelled' THEN a.AppointmentID END) AS CancelledAppointments,
    ROUND(COUNT(DISTINCT a.AppointmentID) / 
        (SELECT COUNT(DISTINCT DoctorID) FROM Doctors WHERE Specialization = d.Specialization), 2) AS AverageComparedToSpecialty
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization
ORDER BY TotalAppointments DESC;

-- Query 4: Appointment Trends by Department
SELECT 
    dp.DepartmentName,
    MONTH(a.AppointmentDate) AS Month,
    YEAR(a.AppointmentDate) AS Year,
    COUNT(*) AS AppointmentCount,
    COUNT(CASE WHEN a.Status = 'Completed' THEN 1 END) AS CompletedCount,
    COUNT(CASE WHEN a.Status = 'No-Show' THEN 1 END) AS NoShowCount,
    ROUND(COUNT(CASE WHEN a.Status = 'No-Show' THEN 1 END) * 100.0 / COUNT(*), 2) AS NoShowPercentage
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dp ON d.DepartmentID = dp.DepartmentID
WHERE YEAR(a.AppointmentDate) = YEAR(CURDATE()) OR YEAR(a.AppointmentDate) = YEAR(CURDATE()) - 1
GROUP BY dp.DepartmentID, dp.DepartmentName, YEAR(a.AppointmentDate), MONTH(a.AppointmentDate)
ORDER BY Year DESC, Month DESC, AppointmentCount DESC;

-- Query 5: Lab Test Abnormality Rate by Test Type
SELECT 
    lt.TestName,
    lt.TestCode,
    COUNT(*) AS TotalTests,
    COUNT(CASE WHEN lr.Status = 'Normal' THEN 1 END) AS NormalResults,
    COUNT(CASE WHEN lr.Status = 'Abnormal' THEN 1 END) AS AbnormalResults,
    COUNT(CASE WHEN lr.Status = 'Critical' THEN 1 END) AS CriticalResults,
    ROUND(COUNT(CASE WHEN lr.Status = 'Abnormal' THEN 1 END) * 100.0 / COUNT(*), 2) AS AbnormalityRate,
    ROUND(COUNT(CASE WHEN lr.Status = 'Critical' THEN 1 END) * 100.0 / COUNT(*), 2) AS CriticalityRate,
    ROUND(AVG(lr.TestValue), 2) AS AverageValue,
    MIN(lr.TestValue) AS MinValue,
    MAX(lr.TestValue) AS MaxValue
FROM LabTests lt
LEFT JOIN LabResults lr ON lt.LabTestID = lr.LabTestID
GROUP BY lt.LabTestID, lt.TestName, lt.TestCode
ORDER BY AbnormalityRate DESC;

-- ============================================================================
-- 2. PATIENT DEMOGRAPHICS AND SEGMENTATION
-- ============================================================================

-- Query 6: Patient Age Distribution and Risk Profiling
SELECT 
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(p.DateOfBirth) < 18 THEN 'Pediatric (0-17)'
        WHEN YEAR(CURDATE()) - YEAR(p.DateOfBirth) BETWEEN 18 AND 30 THEN 'Young Adult (18-30)'
        WHEN YEAR(CURDATE()) - YEAR(p.DateOfBirth) BETWEEN 31 AND 50 THEN 'Middle Age (31-50)'
        WHEN YEAR(CURDATE()) - YEAR(p.DateOfBirth) BETWEEN 51 AND 65 THEN 'Senior (51-65)'
        ELSE 'Elderly (65+)'
    END AS AgeGroup,
    COUNT(*) AS PatientCount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Patients), 2) AS PercentageOfTotal,
    COUNT(DISTINCT CASE WHEN mr.Diagnosis IS NOT NULL THEN p.PatientID END) AS PatientsWithDiagnosis,
    COUNT(DISTINCT CASE WHEN lr.Status = 'Abnormal' THEN p.PatientID END) AS PatientsWithAbnormalLabs
FROM Patients p
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID AND lr.Status = 'Abnormal'
GROUP BY AgeGroup
ORDER BY 
    CASE 
        WHEN AgeGroup = 'Pediatric (0-17)' THEN 1
        WHEN AgeGroup = 'Young Adult (18-30)' THEN 2
        WHEN AgeGroup = 'Middle Age (31-50)' THEN 3
        WHEN AgeGroup = 'Senior (51-65)' THEN 4
        ELSE 5
    END;

-- Query 7: Blood Type Distribution Analysis
SELECT 
    p.BloodType,
    COUNT(*) AS PatientCount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Patients), 2) AS PercentageOfTotal,
    COUNT(DISTINCT CASE WHEN p.PreexistingConditions IS NOT NULL AND p.PreexistingConditions != '' THEN p.PatientID END) AS PatientsWithConditions,
    AVG(YEAR(CURDATE()) - YEAR(p.DateOfBirth)) AS AverageAge
FROM Patients p
GROUP BY p.BloodType
ORDER BY PatientCount DESC;

-- Query 8: Insurance Provider Performance and Patient Distribution
SELECT 
    p.InsuranceProvider,
    COUNT(*) AS CoveredPatients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Patients WHERE InsuranceProvider IS NOT NULL), 2) AS PercentageOfCovered,
    COUNT(DISTINCT b.BillingID) AS BillingRecords,
    SUM(CASE WHEN b.Status = 'Paid' THEN b.Amount ELSE 0 END) AS TotalPaid,
    SUM(CASE WHEN b.Status = 'Pending' THEN b.Amount ELSE 0 END) AS PendingAmount,
    ROUND(AVG(b.Amount), 2) AS AverageClaimAmount,
    COUNT(DISTINCT CASE WHEN b.Status = 'Overdue' THEN b.BillingID END) AS OverdueAccounts
FROM Patients p
LEFT JOIN Billing b ON p.PatientID = b.PatientID
WHERE p.InsuranceProvider IS NOT NULL
GROUP BY p.InsuranceProvider
ORDER BY CoveredPatients DESC;

-- ============================================================================
-- 3. MEDICATION AND PRESCRIPTION ANALYSIS
-- ============================================================================

-- Query 9: Most Prescribed Medications
SELECT 
    m.MedicationName,
    m.ActiveIngredient,
    COUNT(*) AS PrescriptionCount,
    COUNT(DISTINCT pr.PatientID) AS UniquePatients,
    GROUP_CONCAT(DISTINCT pr.Dosage SEPARATOR ', ') AS CommonDosages,
    ROUND(AVG(pr.Duration), 1) AS AverageDuration,
    GROUP_CONCAT(DISTINCT CONCAT(d.FirstName, ' ', d.LastName) ORDER BY d.FirstName SEPARATOR ', ') AS PrescribingDoctors
FROM Medications m
LEFT JOIN Prescriptions pr ON m.MedicationID = pr.MedicationID
LEFT JOIN Doctors d ON pr.DoctorID = d.DoctorID
GROUP BY m.MedicationID, m.MedicationName, m.ActiveIngredient
ORDER BY PrescriptionCount DESC;

-- Query 10: Drug-Disease Association (Most Common Prescriptions for Each Diagnosis)
SELECT 
    mr.Diagnosis,
    m.MedicationName,
    COUNT(*) AS PrescriptionCount,
    COUNT(DISTINCT pr.PatientID) AS AffectedPatients,
    ROUND(AVG(pr.Duration), 1) AS AverageTreatmentDuration
FROM MedicalRecords mr
JOIN Appointments a ON mr.AppointmentID = a.AppointmentID
JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
JOIN Medications m ON pr.MedicationID = m.MedicationID
GROUP BY mr.Diagnosis, m.MedicationID, m.MedicationName
ORDER BY mr.Diagnosis, PrescriptionCount DESC;

-- ============================================================================
-- 4. BILLING AND FINANCIAL ANALYSIS
-- ============================================================================

-- Query 11: Billing Status Overview and Financial Health
SELECT 
    b.Status AS BillingStatus,
    COUNT(*) AS TotalBills,
    SUM(b.Amount) AS TotalAmount,
    ROUND(AVG(b.Amount), 2) AS AverageAmount,
    MIN(b.Amount) AS MinAmount,
    MAX(b.Amount) AS MaxAmount,
    ROUND(
        (DATEDIFF(CURDATE(), b.DueDate) / 
            (SELECT AVG(DATEDIFF(CURDATE(), DueDate)) FROM Billing WHERE Status = 'Overdue')) * 100, 
        2
    ) AS AverageDaysOverdue
FROM Billing b
GROUP BY b.Status
ORDER BY TotalAmount DESC;

-- Query 12: Revenue by Department
SELECT 
    dp.DepartmentName,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT b.BillingID) AS BillingRecords,
    SUM(b.Amount) AS TotalRevenue,
    ROUND(AVG(b.Amount), 2) AS AverageRevenuePerBill,
    SUM(CASE WHEN b.Status = 'Paid' THEN b.Amount ELSE 0 END) AS PaidRevenue,
    SUM(CASE WHEN b.Status = 'Pending' THEN b.Amount ELSE 0 END) AS PendingRevenue,
    SUM(CASE WHEN b.Status = 'Overdue' THEN b.Amount ELSE 0 END) AS OverdueRevenue
FROM Departments dp
LEFT JOIN Doctors d ON dp.DepartmentID = d.DepartmentID
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
GROUP BY dp.DepartmentID, dp.DepartmentName
ORDER BY TotalRevenue DESC;

-- Query 13: Patient Payment Behavior Analysis
SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.PatientID,
    p.InsuranceProvider,
    COUNT(b.BillingID) AS TotalBills,
    SUM(b.Amount) AS TotalBillAmount,
    SUM(CASE WHEN b.Status = 'Paid' THEN b.Amount ELSE 0 END) AS PaidAmount,
    SUM(CASE WHEN b.Status = 'Pending' THEN b.Amount ELSE 0 END) AS PendingAmount,
    SUM(CASE WHEN b.Status = 'Overdue' THEN b.Amount ELSE 0 END) AS OverdueAmount,
    COUNT(CASE WHEN b.Status = 'Overdue' THEN 1 END) AS OverdueCount,
    ROUND(
        SUM(CASE WHEN b.Status = 'Paid' THEN b.Amount ELSE 0 END) * 100.0 / SUM(b.Amount), 
        2
    ) AS PaymentPercentage
FROM Patients p
LEFT JOIN Billing b ON p.PatientID = b.PatientID
GROUP BY p.PatientID, p.FirstName, p.LastName, p.InsuranceProvider
HAVING COUNT(b.BillingID) > 0
ORDER BY OverdueAmount DESC;

-- ============================================================================
-- 5. CLINICAL OUTCOME AND FOLLOW-UP ANALYSIS
-- ============================================================================

-- Query 14: Treatment Completion Rate and Patient Follow-up
SELECT 
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Completed' THEN a.AppointmentID END) AS CompletedAppointments,
    COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), a.AppointmentDate) > 90 
                             AND a.Status = 'Completed' THEN p.PatientID END) AS PatientsNeedingFollowup,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.Status = 'Completed' THEN a.AppointmentID END) * 100.0 / 
        COUNT(DISTINCT a.AppointmentID), 
        2
    ) AS CompletionRate,
    COUNT(DISTINCT pr.PrescriptionID) AS PrescriptionsIssued,
    ROUND(AVG(pr.Duration), 2) AS AverageTreatmentDuration
FROM Doctors d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
LEFT JOIN Patients p ON a.PatientID = p.PatientID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization
ORDER BY CompletionRate DESC;

-- Query 15: Readmission Rate Analysis
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.BloodType,
    COUNT(DISTINCT a.AppointmentID) AS TotalVisits,
    COUNT(DISTINCT mr.RecordID) AS DiagnosisRecords,
    COUNT(DISTINCT CASE WHEN DATEDIFF(a.AppointmentDate, 
        LAG(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate)) 
        < 30 THEN a.AppointmentID END) AS RevisitsWithin30Days,
    COUNT(DISTINCT CASE WHEN DATEDIFF(a.AppointmentDate, 
        LAG(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate)) 
        BETWEEN 30 AND 90 THEN a.AppointmentID END) AS RevisitsBetween30-90Days
FROM Patients p
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
GROUP BY p.PatientID
HAVING COUNT(DISTINCT a.AppointmentID) > 1
ORDER BY TotalVisits DESC;
