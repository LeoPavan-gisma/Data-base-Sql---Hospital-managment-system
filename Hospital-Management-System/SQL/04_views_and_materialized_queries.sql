

USE HospitalManagement;

-- View 1: Complete Patient Profile
CREATE OR REPLACE VIEW vw_PatientProfile AS
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.DateOfBirth,
    YEAR(CURDATE()) - YEAR(p.DateOfBirth) AS Age,
    p.Gender,
    p.BloodType,
    p.Email,
    p.Phone,
    p.Address,
    p.PreexistingConditions,
    p.Allergies,
    p.InsuranceProvider,
    p.InsurancePolicyNumber,
    p.RegistrationDate,
    COUNT(DISTINCT apt.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT mr.RecordID) AS MedicalRecords,
    COUNT(DISTINCT pr.PrescriptionID) AS ActivePrescriptions,
    COUNT(DISTINCT lr.LabResultID) AS LabResults
FROM Patients p
LEFT JOIN Appointments apt ON p.PatientID = apt.PatientID
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
LEFT JOIN Prescriptions pr ON p.PatientID = pr.PatientID
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID
GROUP BY p.PatientID;

-- View 2: Doctor Availability and Schedule
CREATE OR REPLACE VIEW vw_DoctorSchedule AS
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    dp.DepartmentName,
    d.AvailabilityStatus,
    d.YearsOfExperience,
    COUNT(DISTINCT CASE WHEN a.Status = 'Scheduled' THEN a.AppointmentID END) AS ScheduledAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Completed' THEN a.AppointmentID END) AS CompletedAppointments,
    COUNT(DISTINCT CASE WHEN DATE(a.AppointmentDate) = CURDATE() THEN a.AppointmentID END) AS TodaysAppointments,
    GROUP_CONCAT(CONCAT(DATE(a.AppointmentDate), ' - ', TIME(a.AppointmentDate)) 
                 ORDER BY a.AppointmentDate SEPARATOR '; ') AS UpcomingAppointments
FROM Doctors d
LEFT JOIN Departments dp ON d.DepartmentID = dp.DepartmentID
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID AND a.Status IN ('Scheduled', 'Completed')
GROUP BY d.DoctorID;

-- View 3: Recent Lab Results
CREATE OR REPLACE VIEW vw_RecentLabResults AS
SELECT 
    lr.LabResultID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    lt.TestName,
    lt.TestCode,
    lr.TestValue,
    lt.Unit,
    lt.NormalRangeMin,
    lt.NormalRangeMax,
    lr.Status,
    lr.ResultDate,
    CASE 
        WHEN lr.TestValue < lt.NormalRangeMin THEN 'Below Normal'
        WHEN lr.TestValue > lt.NormalRangeMax THEN 'Above Normal'
        ELSE 'Within Normal Range'
    END AS ValueRange,
    DATEDIFF(CURDATE(), DATE(lr.ResultDate)) AS DaysSinceResult
FROM LabResults lr
JOIN Patients p ON lr.PatientID = p.PatientID
JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
WHERE lr.ResultDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY lr.ResultDate DESC;

-- View 4: Active Prescriptions
CREATE OR REPLACE VIEW vw_ActivePrescriptions AS
SELECT 
    pr.PrescriptionID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    m.MedicationName,
    m.ActiveIngredient,
    pr.Dosage,
    pr.Frequency,
    pr.Duration,
    pr.DurationUnit,
    pr.StartDate,
    DATE_ADD(pr.StartDate, INTERVAL pr.Duration DAY) AS EndDate,
    DATEDIFF(DATE_ADD(pr.StartDate, INTERVAL pr.Duration DAY), CURDATE()) AS RemainingDays,
    pr.Instructions,
    CASE 
        WHEN CURDATE() < DATE_ADD(pr.StartDate, INTERVAL pr.Duration DAY) THEN 'Active'
        ELSE 'Expired'
    END AS Status
FROM Prescriptions pr
JOIN Patients p ON pr.PatientID = p.PatientID
JOIN Doctors d ON pr.DoctorID = d.DoctorID
JOIN Medications m ON pr.MedicationID = m.MedicationID
WHERE CURDATE() <= DATE_ADD(pr.StartDate, INTERVAL pr.Duration DAY)
ORDER BY pr.StartDate DESC;

-- View 5: Upcoming Appointments
CREATE OR REPLACE VIEW vw_UpcomingAppointments AS
SELECT 
    a.AppointmentID,
    a.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    a.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    dp.DepartmentName,
    a.AppointmentDate,
    TIME(a.AppointmentDate) AS AppointmentTime,
    a.ReasonForVisit,
    a.Status,
    DATEDIFF(a.AppointmentDate, CURDATE()) AS DaysUntilAppointment,
    p.Phone AS PatientPhone,
    p.Email AS PatientEmail
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
JOIN Departments dp ON d.DepartmentID = dp.DepartmentID
WHERE a.AppointmentDate >= CURDATE() AND a.Status = 'Scheduled'
ORDER BY a.AppointmentDate ASC;

-- View 6: Billing Overview by Patient
CREATE OR REPLACE VIEW vw_PatientBilling AS
SELECT 
    b.BillingID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.InsuranceProvider,
    b.Amount,
    b.ServiceDescription,
    b.BillingDate,
    b.DueDate,
    b.PaidDate,
    b.Status,
    b.PaymentMethod,
    b.InsuranceCovered,
    b.PatientResponsibility,
    CASE 
        WHEN b.Status = 'Overdue' THEN DATEDIFF(CURDATE(), b.DueDate)
        ELSE 0
    END AS DaysOverdue,
    a.AppointmentDate,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName
FROM Billing b
JOIN Patients p ON b.PatientID = p.PatientID
JOIN Appointments a ON b.AppointmentID = a.AppointmentID
JOIN Doctors d ON a.DoctorID = d.DoctorID
ORDER BY b.BillingDate DESC;

-- View 7: Medical Records Summary
CREATE OR REPLACE VIEW vw_MedicalRecordsSummary AS
SELECT 
    mr.RecordID,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    mr.Diagnosis,
    mr.TreatmentPlan,
    mr.ClinicalNotes,
    mr.RecordDate,
    mr.Status,
    COUNT(DISTINCT pr.PrescriptionID) AS PrescriptionsIssued,
    GROUP_CONCAT(DISTINCT m.MedicationName SEPARATOR ', ') AS Medications,
    DATEDIFF(CURDATE(), DATE(mr.RecordDate)) AS DaysSinceRecord
FROM MedicalRecords mr
JOIN Patients p ON mr.PatientID = p.PatientID
JOIN Doctors d ON mr.DoctorID = d.DoctorID
LEFT JOIN Appointments a ON mr.AppointmentID = a.AppointmentID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
LEFT JOIN Medications m ON pr.MedicationID = m.MedicationID
GROUP BY mr.RecordID
ORDER BY mr.RecordDate DESC;

-- View 8: Department Workload
CREATE OR REPLACE VIEW vw_DepartmentWorkload AS
SELECT 
    dp.DepartmentID,
    dp.DepartmentName,
    dp.HeadOfDepartment,
    COUNT(DISTINCT d.DoctorID) AS TotalDoctors,
    COUNT(DISTINCT CASE WHEN d.AvailabilityStatus = 'Available' THEN d.DoctorID END) AS AvailableDoctors,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Scheduled' THEN a.AppointmentID END) AS ScheduledAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'Completed' THEN a.AppointmentID END) AS CompletedAppointments,
    COUNT(DISTINCT CASE WHEN a.Status = 'No-Show' THEN a.AppointmentID END) AS NoShowAppointments,
    COUNT(DISTINCT p.PatientID) AS UniquePatients,
    ROUND(AVG(DATEDIFF(CURDATE(), a.AppointmentDate)), 2) AS AverageDaysSinceAppointment
FROM Departments dp
LEFT JOIN Doctors d ON dp.DepartmentID = d.DepartmentID
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
LEFT JOIN Patients p ON a.PatientID = p.PatientID
GROUP BY dp.DepartmentID, dp.DepartmentName, dp.HeadOfDepartment;

-- View 9: High-Risk Patient Alert
CREATE OR REPLACE VIEW vw_HighRiskPatients AS
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.BloodType,
    YEAR(CURDATE()) - YEAR(p.DateOfBirth) AS Age,
    p.PreexistingConditions,
    p.Allergies,
    COUNT(DISTINCT CASE WHEN lr.Status IN ('Abnormal', 'Critical') THEN lr.LabResultID END) AS AbnormalLabCount,
    COUNT(DISTINCT mr.RecordID) AS DiagnosisCount,
    GROUP_CONCAT(DISTINCT mr.Diagnosis SEPARATOR ', ') AS Diagnoses,
    GROUP_CONCAT(DISTINCT lt.TestName ORDER BY lr.Status DESC SEPARATOR ', ') AS AbnormalTests,
    MAX(lr.ResultDate) AS LastLabDate,
    MAX(a.AppointmentDate) AS LastAppointmentDate,
    'ALERT' AS RiskStatus
FROM Patients p
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID
LEFT JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
LEFT JOIN Appointments a ON p.PatientID = a.PatientID
GROUP BY p.PatientID
HAVING COUNT(DISTINCT CASE WHEN lr.Status IN ('Abnormal', 'Critical') THEN lr.LabResultID END) > 0
    OR COUNT(DISTINCT mr.RecordID) > 1;

-- View 10: Inventory Status
CREATE OR REPLACE VIEW vw_InventoryStatus AS
SELECT 
    InventoryID,
    ItemName,
    ItemType,
    Quantity,
    MinimumQuantity,
    Unit,
    Location,
    Vendor,
    ExpiryDate,
    CASE 
        WHEN Quantity <= MinimumQuantity THEN 'Low Stock'
        WHEN ExpiryDate IS NOT NULL AND ExpiryDate <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'Near Expiry'
        WHEN ExpiryDate IS NOT NULL AND ExpiryDate < CURDATE() THEN 'Expired'
        ELSE 'OK'
    END AS Status,
    CASE 
        WHEN ExpiryDate IS NOT NULL THEN DATEDIFF(ExpiryDate, CURDATE())
        ELSE NULL
    END AS DaysUntilExpiry,
    LastRestockedDate
FROM Inventory
ORDER BY Status ASC, Quantity ASC;
