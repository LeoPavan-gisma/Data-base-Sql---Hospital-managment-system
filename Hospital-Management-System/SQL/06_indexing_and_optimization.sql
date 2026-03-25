-- Hospital Management System - Performance Optimization and Indexes
-- M605 Database Project - Query Performance Tuning

USE HospitalManagement;

-- ============================================================================
-- COMPREHENSIVE INDEXING STRATEGY
-- ============================================================================

-- Department Indexes
CREATE INDEX idx_dep_name ON Departments(DepartmentName);
CREATE INDEX idx_dep_budget ON Departments(Budget);

-- Doctor Indexes (already created in schema but adding composite indexes)
CREATE INDEX idx_doc_name ON Doctors(FirstName, LastName);
CREATE INDEX idx_doc_license ON Doctors(LicenseNumber);
CREATE INDEX idx_doc_dept_spec ON Doctors(DepartmentID, Specialization);
CREATE INDEX idx_doc_availability ON Doctors(AvailabilityStatus);

-- Patient Indexes (already created but enhancing)
CREATE INDEX idx_pat_name ON Patients(FirstName, LastName);
CREATE INDEX idx_pat_email ON Patients(Email);
CREATE INDEX idx_pat_phone ON Patients(Phone);
CREATE INDEX idx_pat_dob_gender ON Patients(DateOfBirth, Gender);
CREATE INDEX idx_pat_insurance ON Patients(InsuranceProvider, InsurancePolicyNumber);
CREATE INDEX idx_pat_registration_date ON Patients(RegistrationDate);

-- Appointment Indexes (already created but adding)
CREATE INDEX idx_apt_date_range ON Appointments(AppointmentDate);
CREATE INDEX idx_apt_patient_doctor ON Appointments(PatientID, DoctorID);
CREATE INDEX idx_apt_status_date ON Appointments(Status, AppointmentDate);
CREATE INDEX idx_apt_endtime ON Appointments(EndTime);

-- Lab Results Indexes
CREATE INDEX idx_lab_patient_date ON LabResults(PatientID, ResultDate);
CREATE INDEX idx_lab_test_status ON LabResults(LabTestID, Status);
CREATE INDEX idx_lab_abnormal_date ON LabResults(Status, ResultDate);
CREATE INDEX idx_lab_value_range ON LabResults(TestValue);

-- Medication Indexes
CREATE INDEX idx_med_name ON Medications(MedicationName);
CREATE INDEX idx_med_ingredient ON Medications(ActiveIngredient);

-- Prescription Indexes
CREATE INDEX idx_presc_patient_date ON Prescriptions(PatientID, StartDate);
CREATE INDEX idx_presc_doctor_patient ON Prescriptions(DoctorID, PatientID);
CREATE INDEX idx_presc_medication ON Prescriptions(MedicationID);
CREATE INDEX idx_presc_active ON Prescriptions(StartDate, Duration);

-- Medical Records Indexes
CREATE INDEX idx_med_rec_patient ON MedicalRecords(PatientID);
CREATE INDEX idx_med_rec_doctor ON MedicalRecords(DoctorID);
CREATE INDEX idx_med_rec_diagnosis ON MedicalRecords(Diagnosis);
CREATE INDEX idx_med_rec_date_status ON MedicalRecords(RecordDate, Status);

-- Billing Indexes
CREATE INDEX idx_bill_patient ON Billing(PatientID);
CREATE INDEX idx_bill_apt ON Billing(AppointmentID);
CREATE INDEX idx_bill_status_date ON Billing(Status, BillingDate);
CREATE INDEX idx_bill_due_date ON Billing(DueDate);
CREATE INDEX idx_bill_insurance ON Billing(PatientID, Status);

-- Inventory Indexes
CREATE INDEX idx_inv_type_quantity ON Inventory(ItemType, Quantity);
CREATE INDEX idx_inv_expiry ON Inventory(ExpiryDate);
CREATE INDEX idx_inv_location ON Inventory(Location);

-- Staff Indexes
CREATE INDEX idx_staff_type_dept ON Staff(StaffType, DepartmentID);
CREATE INDEX idx_staff_status ON Staff(Status);

-- ============================================================================
-- FULL TEXT SEARCH INDEXES
-- ============================================================================

-- Patient Clinical Information Search
ALTER TABLE Patients ADD FULLTEXT idx_ft_patient_clinical 
    (PreexistingConditions, Allergies);

-- Medical Records Full Text Search
ALTER TABLE MedicalRecords ADD FULLTEXT idx_ft_medical_records 
    (Diagnosis, TreatmentPlan, ClinicalNotes);

-- Medication Full Text Search
ALTER TABLE Medications ADD FULLTEXT idx_ft_medications 
    (MedicationName, ActiveIngredient, SideEffects);

-- Appointment Reason Search
ALTER TABLE Appointments ADD FULLTEXT idx_ft_appointment_reason 
    (ReasonForVisit, Notes);

-- ============================================================================
-- QUERY OPTIMIZATION - ANALYZE TABLE STATISTICS
-- ============================================================================

ANALYZE TABLE Patients;
ANALYZE TABLE Doctors;
ANALYZE TABLE Departments;
ANALYZE TABLE Appointments;
ANALYZE TABLE LabResults;
ANALYZE TABLE LabTests;
ANALYZE TABLE Medications;
ANALYZE TABLE Prescriptions;
ANALYZE TABLE MedicalRecords;
ANALYZE TABLE Billing;
ANALYZE TABLE Inventory;
ANALYZE TABLE Staff;

-- ============================================================================
-- PERFORMANCE MONITORING QUERIES
-- ============================================================================

-- Query to find missing indexes
SELECT OBJECT_SCHEMA, OBJECT_NAME, COUNT(*) as potential_index_count
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE INDEX_NAME = 'PRIMARY'
GROUP BY OBJECT_SCHEMA, OBJECT_NAME
ORDER BY potential_index_count DESC;

-- Check table sizes
SELECT 
    TABLE_NAME,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size in MB'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'HospitalManagement'
ORDER BY (data_length + index_length) DESC;

-- ============================================================================
-- TRIGGER FOR AUDIT LOGGING
-- ============================================================================

-- Create audit log table
CREATE TABLE IF NOT EXISTS AuditLog (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(100),
    Operation VARCHAR(20),
    RecordID INT,
    OldValue TEXT,
    NewValue TEXT,
    ChangedBy VARCHAR(100),
    ChangedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IPAddress VARCHAR(45),
    INDEX idx_audit_table (TableName),
    INDEX idx_audit_date (ChangedDate)
);

-- Trigger for Patients table audit
DELIMITER $$

CREATE TRIGGER trg_patient_audit_update
AFTER UPDATE ON Patients
FOR EACH ROW
BEGIN
    IF OLD.FirstName != NEW.FirstName OR OLD.LastName != NEW.LastName OR 
       OLD.Email != NEW.Email OR OLD.Phone != NEW.Phone THEN
        INSERT INTO AuditLog (TableName, Operation, RecordID, OldValue, NewValue, ChangedDate)
        VALUES ('Patients', 'UPDATE', NEW.PatientID, 
                CONCAT(OLD.FirstName, ' ', OLD.LastName, ' - ', OLD.Email),
                CONCAT(NEW.FirstName, ' ', NEW.LastName, ' - ', NEW.Email),
                NOW());
    END IF;
END$$

DELIMITER ;

-- Trigger to update MedicalRecords LastModified timestamp
DELIMITER $$

CREATE TRIGGER trg_medicalrecord_timestamp
BEFORE UPDATE ON MedicalRecords
FOR EACH ROW
BEGIN
    SET NEW.LastModified = NOW();
END$$

DELIMITER ;

-- ============================================================================
-- STORED PROCEDURES FOR MAINTENANCE
-- ============================================================================

-- Procedure to archive old appointments
DELIMITER $$

CREATE PROCEDURE sp_ArchiveOldRecords(
    IN p_MonthsOld INT,
    OUT p_RowsArchived INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_RowsArchived = -1;
    END;
    
    -- Archive completed appointments older than specified months
    DELETE FROM Appointments
    WHERE Status = 'Completed' 
      AND AppointmentDate < DATE_SUB(CURDATE(), INTERVAL p_MonthsOld MONTH);
    
    SET p_RowsArchived = ROW_COUNT();
END$$

DELIMITER ;

-- Procedure to generate database statistics report
DELIMITER $$

CREATE PROCEDURE sp_DatabaseStatisticsReport()
BEGIN
    SELECT 'HOSPITAL DATABASE STATISTICS REPORT' AS ReportHeader;
    SELECT '' AS BlankLine;
    
    SELECT 'PATIENT STATISTICS' AS Section;
    SELECT 
        COUNT(*) AS TotalPatients,
        COUNT(DISTINCT Gender) AS GenderCount,
        MIN(DateOfBirth) AS OldestPatientDOB,
        MAX(DateOfBirth) AS YoungestPatientDOB,
        COUNT(DISTINCT BloodType) AS BloodTypeVariety
    FROM Patients;
    
    SELECT '' AS BlankLine;
    SELECT 'DOCTOR STATISTICS' AS Section;
    SELECT 
        COUNT(*) AS TotalDoctors,
        COUNT(DISTINCT Specialization) AS SpecializationCount,
        AVG(YearsOfExperience) AS AverageYearsExperience,
        COUNT(DISTINCT DepartmentID) AS DepartmentCount
    FROM Doctors;
    
    SELECT '' AS BlankLine;
    SELECT 'APPOINTMENT STATISTICS' AS Section;
    SELECT 
        COUNT(*) AS TotalAppointments,
        COUNT(CASE WHEN Status = 'Completed' THEN 1 END) AS CompletedAppointments,
        COUNT(CASE WHEN Status = 'Scheduled' THEN 1 END) AS ScheduledAppointments,
        COUNT(CASE WHEN Status = 'Cancelled' THEN 1 END) AS CancelledAppointments,
        COUNT(CASE WHEN Status = 'No-Show' THEN 1 END) AS NoShowAppointments
    FROM Appointments;
    
    SELECT '' AS BlankLine;
    SELECT 'LAB RESULTS STATISTICS' AS Section;
    SELECT 
        COUNT(*) AS TotalResults,
        COUNT(CASE WHEN Status = 'Normal' THEN 1 END) AS NormalResults,
        COUNT(CASE WHEN Status = 'Abnormal' THEN 1 END) AS AbnormalResults,
        COUNT(CASE WHEN Status = 'Critical' THEN 1 END) AS CriticalResults,
        COUNT(DISTINCT LabTestID) AS UniqueLabs
    FROM LabResults;
    
    SELECT '' AS BlankLine;
    SELECT 'BILLING STATISTICS' AS Section;
    SELECT 
        COUNT(*) AS TotalBills,
        SUM(Amount) AS TotalBillingAmount,
        SUM(CASE WHEN Status = 'Paid' THEN Amount ELSE 0 END) AS PaidAmount,
        SUM(CASE WHEN Status = 'Pending' THEN Amount ELSE 0 END) AS PendingAmount,
        SUM(CASE WHEN Status = 'Overdue' THEN Amount ELSE 0 END) AS OverdueAmount,
        ROUND(AVG(Amount), 2) AS AverageBillAmount
    FROM Billing;
END$$

DELIMITER ;

-- ============================================================================
-- DATA INTEGRITY CHECKS
-- ============================================================================

-- Check for orphaned appointments (no corresponding patient)
SELECT 'Orphaned Appointments Check' AS CheckType;
SELECT a.AppointmentID, a.PatientID FROM Appointments a
LEFT JOIN Patients p ON a.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

-- Check for orphaned medical records
SELECT 'Orphaned Medical Records Check' AS CheckType;
SELECT mr.RecordID, mr.PatientID FROM MedicalRecords mr
LEFT JOIN Patients p ON mr.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

-- Check for orphaned prescriptions
SELECT 'Orphaned Prescriptions Check' AS CheckType;
SELECT pr.PrescriptionID, pr.PatientID FROM Prescriptions pr
LEFT JOIN Patients p ON pr.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

-- Check for orphaned lab results
SELECT 'Orphaned Lab Results Check' AS CheckType;
SELECT lr.LabResultID, lr.PatientID FROM LabResults lr
LEFT JOIN Patients p ON lr.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

-- Check for invalid billing references
SELECT 'Invalid Billing References Check' AS CheckType;
SELECT b.BillingID FROM Billing b
LEFT JOIN Appointments a ON b.AppointmentID = a.AppointmentID
WHERE a.AppointmentID IS NULL;
