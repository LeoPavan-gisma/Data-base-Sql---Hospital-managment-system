-- Hospital Management System - CRUD Operations and Additional Queries
-- M605 Advanced Databases - SQL Operations
-- Comprehensive CRUD examples for all tables

-- ============================================================================
-- CREATE OPERATIONS
-- ============================================================================

-- CREATE: Insert new patient with validation
DELIMITER //
CREATE PROCEDURE sp_InsertPatient(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DOB DATE,
    IN p_Gender VARCHAR(10),
    IN p_Email VARCHAR(100),
    IN p_Phone VARCHAR(15),
    IN p_BloodType VARCHAR(5),
    IN p_Address TEXT,
    IN p_Insurance VARCHAR(100),
    IN p_PolicyNumber VARCHAR(50),
    OUT p_PatientID INT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error creating patient record';
    END;
    
    IF p_Email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
        SET p_Message = 'Invalid email format';
    ELSEIF p_BloodType NOT IN ('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') THEN
        SET p_Message = 'Invalid blood type';
    ELSE
        INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, Email, Phone, BloodType, Address, InsuranceProvider, PolicyNumber)
        VALUES (p_FirstName, p_LastName, p_DOB, p_Gender, p_Email, p_Phone, p_BloodType, p_Address, p_Insurance, p_PolicyNumber);
        
        SET p_PatientID = LAST_INSERT_ID();
        SET p_Message = 'Patient created successfully';
    END IF;
END //
DELIMITER ;

-- CREATE: Insert new doctor
DELIMITER //
CREATE PROCEDURE sp_InsertDoctor(
    IN p_LicenseNumber VARCHAR(20),
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DepartmentID INT,
    IN p_Specialization VARCHAR(100),
    IN p_YearsOfExperience INT,
    IN p_Email VARCHAR(100),
    IN p_Phone VARCHAR(15),
    OUT p_DoctorID INT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error creating doctor record';
    END;
    
    IF EXISTS (SELECT 1 FROM Doctors WHERE LicenseNumber = p_LicenseNumber) THEN
        SET p_Message = 'License number already exists';
    ELSE
        INSERT INTO Doctors (LicenseNumber, FirstName, LastName, DepartmentID, Specialization, YearsOfExperience, Email, Phone, AvailabilityStatus)
        VALUES (p_LicenseNumber, p_FirstName, p_LastName, p_DepartmentID, p_Specialization, p_YearsOfExperience, p_Email, p_Phone, 'Available');
        
        SET p_DoctorID = LAST_INSERT_ID();
        SET p_Message = 'Doctor created successfully';
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- READ OPERATIONS
-- ============================================================================

-- READ: Get complete patient profile
DELIMITER //
CREATE PROCEDURE sp_GetPatientProfile(
    IN p_PatientID INT
)
BEGIN
    SELECT 
        p.PatientID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.DateOfBirth,
        YEAR(CURDATE()) - YEAR(p.DateOfBirth) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(p.DateOfBirth, '%m%d')) AS Age,
        p.Gender,
        p.Email,
        p.Phone,
        p.BloodType,
        p.Address,
        p.InsuranceProvider,
        p.PolicyNumber,
        p.PreexistingConditions,
        p.Allergies,
        COUNT(DISTINCT a.AppointmentID) AS TotalAppointments,
        COUNT(DISTINCT lr.LabResultID) AS TotalLabTests,
        COUNT(DISTINCT mr.MedicalRecordID) AS TotalMedicalRecords
    FROM Patients p
    LEFT JOIN Appointments a ON p.PatientID = a.PatientID
    LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID
    LEFT JOIN MedicalRecords mr ON p.PatientID = mr.PatientID
    WHERE p.PatientID = p_PatientID
    GROUP BY p.PatientID;
END //
DELIMITER ;

-- READ: Get doctor's appointment schedule
DELIMITER //
CREATE PROCEDURE sp_GetDoctorSchedule(
    IN p_DoctorID INT,
    IN p_StartDate DATE,
    IN p_EndDate DATE
)
BEGIN
    SELECT 
        a.AppointmentID,
        CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
        p.Email,
        p.Phone,
        a.AppointmentDate,
        a.AppointmentTime,
        a.ReasonForVisit,
        a.AppointmentStatus,
        mr.Diagnosis
    FROM Appointments a
    INNER JOIN Patients p ON a.PatientID = p.PatientID
    LEFT JOIN MedicalRecords mr ON a.AppointmentID = mr.AppointmentID
    WHERE a.DoctorID = p_DoctorID
    AND DATE(a.AppointmentDate) BETWEEN p_StartDate AND p_EndDate
    ORDER BY a.AppointmentDate, a.AppointmentTime;
END //
DELIMITER ;

-- READ: Get recent lab results for patient
DELIMITER //
CREATE PROCEDURE sp_GetRecentLabResults(
    IN p_PatientID INT,
    IN p_Days INT
)
BEGIN
    SELECT 
        lr.LabResultID,
        lt.LabTestName,
        lr.TestResult,
        lt.NormalRange,
        lr.TestDate,
        CASE 
            WHEN lr.IsAbnormal = 1 THEN 'Abnormal'
            WHEN lr.IsCritical = 1 THEN 'Critical'
            ELSE 'Normal'
        END AS ResultStatus,
        CONCAT(d.FirstName, ' ', d.LastName) AS OrderedBy
    FROM LabResults lr
    INNER JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
    INNER JOIN Doctors d ON lr.DoctorID = d.DoctorID
    WHERE lr.PatientID = p_PatientID
    AND lr.TestDate >= DATE_SUB(CURDATE(), INTERVAL p_Days DAY)
    ORDER BY lr.TestDate DESC;
END //
DELIMITER ;

-- ============================================================================
-- UPDATE OPERATIONS
-- ============================================================================

-- UPDATE: Update patient information
DELIMITER //
CREATE PROCEDURE sp_UpdatePatient(
    IN p_PatientID INT,
    IN p_Email VARCHAR(100),
    IN p_Phone VARCHAR(15),
    IN p_Address TEXT,
    IN p_PreexistingConditions TEXT,
    IN p_Allergies TEXT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error updating patient record';
    END;
    
    UPDATE Patients
    SET 
        Email = COALESCE(p_Email, Email),
        Phone = COALESCE(p_Phone, Phone),
        Address = COALESCE(p_Address, Address),
        PreexistingConditions = COALESCE(p_PreexistingConditions, PreexistingConditions),
        Allergies = COALESCE(p_Allergies, Allergies),
        UpdatedAt = NOW()
    WHERE PatientID = p_PatientID;
    
    SET p_Message = 'Patient updated successfully';
END //
DELIMITER ;

-- UPDATE: Update appointment status
DELIMITER //
CREATE PROCEDURE sp_UpdateAppointmentStatus(
    IN p_AppointmentID INT,
    IN p_Status VARCHAR(20),
    IN p_Notes TEXT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error updating appointment';
    END;
    
    IF p_Status NOT IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show') THEN
        SET p_Message = 'Invalid appointment status';
    ELSE
        UPDATE Appointments
        SET 
            AppointmentStatus = p_Status,
            Notes = COALESCE(p_Notes, Notes),
            UpdatedAt = NOW()
        WHERE AppointmentID = p_AppointmentID;
        
        SET p_Message = 'Appointment updated successfully';
    END IF;
END //
DELIMITER ;

-- UPDATE: Update lab result status
DELIMITER //
CREATE PROCEDURE sp_UpdateLabResultInterpretation(
    IN p_LabResultID INT,
    IN p_IsAbnormal BOOLEAN,
    IN p_IsCritical BOOLEAN,
    IN p_Interpretation TEXT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error updating lab result';
    END;
    
    UPDATE LabResults
    SET 
        IsAbnormal = p_IsAbnormal,
        IsCritical = p_IsCritical,
        Interpretation = p_Interpretation,
        UpdatedAt = NOW()
    WHERE LabResultID = p_LabResultID;
    
    SET p_Message = 'Lab result updated successfully';
END //
DELIMITER ;

-- ============================================================================
-- DELETE OPERATIONS
-- ============================================================================

-- DELETE: Soft delete patient (mark as inactive)
DELIMITER //
CREATE PROCEDURE sp_DeletePatient(
    IN p_PatientID INT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error deleting patient record';
    END;
    
    -- Check if patient has any active appointments
    IF EXISTS (SELECT 1 FROM Appointments WHERE PatientID = p_PatientID AND AppointmentStatus = 'Scheduled') THEN
        SET p_Message = 'Cannot delete patient with active appointments';
    ELSE
        UPDATE Patients
        SET IsActive = 0, UpdatedAt = NOW()
        WHERE PatientID = p_PatientID;
        
        SET p_Message = 'Patient record deactivated successfully';
    END IF;
END //
DELIMITER ;

-- DELETE: Cancel appointment
DELIMITER //
CREATE PROCEDURE sp_CancelAppointment(
    IN p_AppointmentID INT,
    IN p_CancellationReason TEXT,
    OUT p_Message VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error cancelling appointment';
    END;
    
    UPDATE Appointments
    SET 
        AppointmentStatus = 'Cancelled',
        Notes = CONCAT(Notes, ' | Cancellation Reason: ', p_CancellationReason),
        UpdatedAt = NOW()
    WHERE AppointmentID = p_AppointmentID
    AND AppointmentStatus != 'Completed';
    
    SET p_Message = 'Appointment cancelled successfully';
END //
DELIMITER ;

-- ============================================================================
-- ADVANCED QUERIES
-- ============================================================================

-- Query: Find patients with critical lab values needing immediate attention
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Email,
    p.Phone,
    COUNT(DISTINCT lr.LabResultID) AS CriticalResultCount,
    GROUP_CONCAT(DISTINCT lt.LabTestName) AS CriticalTests,
    MAX(lr.TestDate) AS LatestTestDate
FROM Patients p
INNER JOIN LabResults lr ON p.PatientID = lr.PatientID
INNER JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
WHERE lr.IsCritical = 1
AND lr.TestDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY p.PatientID
HAVING CriticalResultCount > 0
ORDER BY CriticalResultCount DESC;

-- Query: Patient medication history
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    pr.PrescriptionID,
    m.MedicationName,
    pr.Dosage,
    pr.Frequency,
    pr.StartDate,
    pr.EndDate,
    pr.Refills,
    CONCAT(d.FirstName, ' ', d.LastName) AS PrescribedBy,
    CASE 
        WHEN pr.EndDate < CURDATE() THEN 'Expired'
        WHEN pr.EndDate IS NULL THEN 'Active'
        ELSE 'Active'
    END AS PrescriptionStatus
FROM Prescriptions pr
INNER JOIN Patients p ON pr.PatientID = p.PatientID
INNER JOIN Medications m ON pr.MedicationID = m.MedicationID
INNER JOIN Doctors d ON pr.DoctorID = d.DoctorID
WHERE p.PatientID = 1
ORDER BY pr.StartDate DESC;

-- Query: Doctor patient comparison - similar conditions
SELECT 
    d1.DoctorID,
    CONCAT(d1.FirstName, ' ', d1.LastName) AS Doctor1,
    d2.DoctorID AS Doctor2ID,
    CONCAT(d2.FirstName, ' ', d2.LastName) AS Doctor2,
    COUNT(DISTINCT mr.MedicalRecordID) AS SharedPatientDiagnoses,
    GROUP_CONCAT(DISTINCT mr.Diagnosis) AS CommonConditions
FROM Doctors d1
CROSS JOIN Doctors d2
INNER JOIN MedicalRecords mr1 ON d1.DoctorID = mr1.DoctorID
INNER JOIN MedicalRecords mr2 ON d2.DoctorID = mr2.DoctorID
WHERE d1.DoctorID < d2.DoctorID
AND d1.Specialization = d2.Specialization
GROUP BY d1.DoctorID, d2.DoctorID
HAVING SharedPatientDiagnoses > 0;

-- Query: Billing analysis with payment tracking
SELECT 
    b.DepartmentID,
    dep.DepartmentName,
    COUNT(b.BillingID) AS TotalBills,
    SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.Amount ELSE 0 END) AS PaidAmount,
    SUM(CASE WHEN b.PaymentStatus = 'Pending' THEN b.Amount ELSE 0 END) AS PendingAmount,
    SUM(CASE WHEN b.PaymentStatus = 'Overdue' THEN b.Amount ELSE 0 END) AS OverdueAmount,
    SUM(b.Amount) AS TotalAmount,
    ROUND(SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.Amount ELSE 0 END) / SUM(b.Amount) * 100, 2) AS PaymentRate
FROM Billing b
INNER JOIN Departments dep ON b.DepartmentID = dep.DepartmentID
GROUP BY b.DepartmentID, dep.DepartmentName
ORDER BY TotalAmount DESC;

-- Query: Appointment no-show analysis
SELECT 
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.Specialization,
    COUNT(CASE WHEN a.AppointmentStatus = 'Scheduled' THEN 1 END) AS ScheduledAppointments,
    COUNT(CASE WHEN a.AppointmentStatus = 'Completed' THEN 1 END) AS CompletedAppointments,
    COUNT(CASE WHEN a.AppointmentStatus = 'No-Show' THEN 1 END) AS NoShowAppointments,
    COUNT(CASE WHEN a.AppointmentStatus = 'Cancelled' THEN 1 END) AS CancelledAppointments,
    ROUND(COUNT(CASE WHEN a.AppointmentStatus = 'No-Show' THEN 1 END) / COUNT(*) * 100, 2) AS NoShowRate
FROM Appointments a
INNER JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY d.DoctorID, d.FirstName, d.LastName
HAVING NoShowAppointments > 0
ORDER BY NoShowRate DESC;

-- Query: Medication side effects and contraindications check
SELECT 
    m1.MedicationID AS Medication1,
    m1.MedicationName AS Medication1Name,
    m2.MedicationID AS Medication2,
    m2.MedicationName AS Medication2Name,
    'Potential Interaction' AS InteractionType
FROM Medications m1
CROSS JOIN Medications m2
WHERE m1.MedicationID < m2.MedicationID
AND (
    m1.Contraindications LIKE CONCAT('%', m2.MedicationName, '%')
    OR m2.Contraindications LIKE CONCAT('%', m1.MedicationName, '%')
)
ORDER BY m1.MedicationName, m2.MedicationName;

-- Query: Patient length of stay and recovery metrics
SELECT 
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    a.AppointmentDate AS AdmissionDate,
    MAX(a.AppointmentDate) AS DischargeDate,
    DATEDIFF(MAX(a.AppointmentDate), a.AppointmentDate) AS LengthOfStay,
    COUNT(DISTINCT lr.LabResultID) AS LabTestsDuringStay,
    COUNT(DISTINCT pr.PrescriptionID) AS PrescriptionsDuringStay
FROM Patients p
INNER JOIN Appointments a ON p.PatientID = a.PatientID
LEFT JOIN LabResults lr ON p.PatientID = lr.PatientID 
    AND lr.TestDate BETWEEN a.AppointmentDate AND DATE_ADD(a.AppointmentDate, INTERVAL 30 DAY)
LEFT JOIN Prescriptions pr ON p.PatientID = pr.PatientID 
    AND pr.StartDate BETWEEN a.AppointmentDate AND DATE_ADD(a.AppointmentDate, INTERVAL 30 DAY)
WHERE a.AppointmentStatus = 'Completed'
GROUP BY p.PatientID, a.AppointmentDate
ORDER BY LengthOfStay DESC;
