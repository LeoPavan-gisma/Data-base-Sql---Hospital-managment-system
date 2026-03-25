

USE HospitalManagement;


DELIMITER $$

CREATE PROCEDURE sp_AddPatient(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_DateOfBirth DATE,
    IN p_Gender VARCHAR(20),
    IN p_BloodType VARCHAR(3),
    IN p_Email VARCHAR(100),
    IN p_Phone VARCHAR(20),
    IN p_Address VARCHAR(255),
    IN p_EmergencyContact VARCHAR(20),
    IN p_Allergies TEXT,
    IN p_InsuranceProvider VARCHAR(100),
    IN p_InsurancePolicyNumber VARCHAR(50),
    OUT p_PatientID INT,
    OUT p_Message VARCHAR(200)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error: Failed to add patient. Check data validity.';
        SET p_PatientID = -1;
    END;
    
    IF p_FirstName IS NULL OR p_LastName IS NULL OR p_DateOfBirth IS NULL THEN
        SET p_Message = 'Error: First name, last name, and date of birth are required.';
        SET p_PatientID = -1;
    ELSEIF YEAR(CURDATE()) - YEAR(p_DateOfBirth) < 0 THEN
        SET p_Message = 'Error: Invalid date of birth (future date).';
        SET p_PatientID = -1;
    ELSEIF p_Email IS NOT NULL AND p_Email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
        SET p_Message = 'Error: Invalid email format.';
        SET p_PatientID = -1;
    ELSEIF p_BloodType NOT IN ('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') THEN
        SET p_Message = 'Error: Invalid blood type.';
        SET p_PatientID = -1;
    ELSE
        INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, BloodType, Email, Phone, 
                            Address, EmergencyContact, Allergies, InsuranceProvider, InsurancePolicyNumber)
        VALUES (p_FirstName, p_LastName, p_DateOfBirth, p_Gender, p_BloodType, p_Email, p_Phone, 
               p_Address, p_EmergencyContact, p_Allergies, p_InsuranceProvider, p_InsurancePolicyNumber);
        
        SET p_PatientID = LAST_INSERT_ID();
        SET p_Message = CONCAT('Success: Patient added with ID ', p_PatientID);
    END IF;
END$$

DELIMITER ;

-- Procedure 2: Schedule Appointment with Conflict Detection
DELIMITER $$

CREATE PROCEDURE sp_ScheduleAppointment(
    IN p_PatientID INT,
    IN p_DoctorID INT,
    IN p_AppointmentDate DATETIME,
    IN p_ReasonForVisit VARCHAR(255),
    OUT p_AppointmentID INT,
    OUT p_Message VARCHAR(300)
)
BEGIN
    DECLARE v_DoctorExists INT;
    DECLARE v_PatientExists INT;
    DECLARE v_ConflictCount INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error: Failed to schedule appointment.';
        SET p_AppointmentID = -1;
    END;
    
    -- Validate patient exists
    SELECT COUNT(*) INTO v_PatientExists FROM Patients WHERE PatientID = p_PatientID;
    IF v_PatientExists = 0 THEN
        SET p_Message = 'Error: Patient does not exist.';
        SET p_AppointmentID = -1;
    ELSE
        -- Validate doctor exists
        SELECT COUNT(*) INTO v_DoctorExists FROM Doctors WHERE DoctorID = p_DoctorID;
        IF v_DoctorExists = 0 THEN
            SET p_Message = 'Error: Doctor does not exist.';
            SET p_AppointmentID = -1;
        ELSE
            -- Check for doctor conflicts (within 30 minutes)
            SELECT COUNT(*) INTO v_ConflictCount 
            FROM Appointments 
            WHERE DoctorID = p_DoctorID 
              AND Status IN ('Scheduled', 'Completed')
              AND ABS(TIMESTAMPDIFF(MINUTE, AppointmentDate, p_AppointmentDate)) < 30;
            
            IF v_ConflictCount > 0 THEN
                SET p_Message = 'Error: Doctor has conflicting appointment.';
                SET p_AppointmentID = -1;
            ELSE
                INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, ReasonForVisit, Status)
                VALUES (p_PatientID, p_DoctorID, p_AppointmentDate, p_ReasonForVisit, 'Scheduled');
                
                SET p_AppointmentID = LAST_INSERT_ID();
                SET p_Message = CONCAT('Success: Appointment scheduled with ID ', p_AppointmentID);
            END IF;
        END IF;
    END IF;
END$$

DELIMITER ;

-- Procedure 3: Record Lab Result with Automatic Abnormality Flagging
DELIMITER $$

CREATE PROCEDURE sp_RecordLabResult(
    IN p_PatientID INT,
    IN p_LabTestID INT,
    IN p_TestValue DECIMAL(10, 4),
    IN p_TechnicianNotes TEXT,
    OUT p_LabResultID INT,
    OUT p_Status VARCHAR(20),
    OUT p_Message VARCHAR(300)
)
BEGIN
    DECLARE v_NormalMin DECIMAL(10, 2);
    DECLARE v_NormalMax DECIMAL(10, 2);
    DECLARE v_PatientExists INT;
    DECLARE v_TestExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error: Failed to record lab result.';
        SET p_LabResultID = -1;
        SET p_Status = 'Error';
    END;
    
    -- Validate patient exists
    SELECT COUNT(*) INTO v_PatientExists FROM Patients WHERE PatientID = p_PatientID;
    IF v_PatientExists = 0 THEN
        SET p_Message = 'Error: Patient does not exist.';
        SET p_LabResultID = -1;
        SET p_Status = 'Error';
    ELSE
        -- Get normal ranges for the test
        SELECT NormalRangeMin, NormalRangeMax INTO v_NormalMin, v_NormalMax
        FROM LabTests WHERE LabTestID = p_LabTestID;
        
        IF v_NormalMin IS NULL THEN
            SET p_Message = 'Error: Lab test does not exist.';
            SET p_LabResultID = -1;
            SET p_Status = 'Error';
        ELSE
            -- Determine abnormality status
            IF p_TestValue < v_NormalMin OR p_TestValue > v_NormalMax THEN
                SET p_Status = 'Abnormal';
            ELSE
                SET p_Status = 'Normal';
            END IF;
            
            -- Check for critical values (outside by more than 50%)
            IF (p_TestValue < v_NormalMin * 0.5) OR (p_TestValue > v_NormalMax * 1.5) THEN
                SET p_Status = 'Critical';
            END IF;
            
            -- Insert lab result
            INSERT INTO LabResults (PatientID, LabTestID, TestValue, Status, ResultDate, TechnicianNotes)
            VALUES (p_PatientID, p_LabTestID, p_TestValue, p_Status, NOW(), p_TechnicianNotes);
            
            SET p_LabResultID = LAST_INSERT_ID();
            SET p_Message = CONCAT('Success: Lab result recorded (', p_Status, ') with ID ', p_LabResultID);
        END IF;
    END IF;
END$$

DELIMITER ;

-- Procedure 4: Create Medical Record from Appointment
DELIMITER $$

CREATE PROCEDURE sp_CreateMedicalRecord(
    IN p_AppointmentID INT,
    IN p_Diagnosis VARCHAR(255),
    IN p_TreatmentPlan TEXT,
    IN p_ClinicalNotes TEXT,
    OUT p_RecordID INT,
    OUT p_Message VARCHAR(300)
)
BEGIN
    DECLARE v_PatientID INT;
    DECLARE v_DoctorID INT;
    DECLARE v_AppointmentExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error: Failed to create medical record.';
        SET p_RecordID = -1;
    END;
    
    -- Check if appointment exists
    SELECT COUNT(*), PatientID, DoctorID INTO v_AppointmentExists, v_PatientID, v_DoctorID
    FROM Appointments WHERE AppointmentID = p_AppointmentID;
    
    IF v_AppointmentExists = 0 THEN
        SET p_Message = 'Error: Appointment does not exist.';
        SET p_RecordID = -1;
    ELSE
        INSERT INTO MedicalRecords (PatientID, DoctorID, AppointmentID, Diagnosis, TreatmentPlan, ClinicalNotes, RecordDate, Status)
        VALUES (v_PatientID, v_DoctorID, p_AppointmentID, p_Diagnosis, p_TreatmentPlan, p_ClinicalNotes, NOW(), 'Finalized');
        
        SET p_RecordID = LAST_INSERT_ID();
        
        -- Update appointment status
        UPDATE Appointments SET Status = 'Completed' WHERE AppointmentID = p_AppointmentID;
        
        SET p_Message = CONCAT('Success: Medical record created with ID ', p_RecordID);
    END IF;
END$$

DELIMITER ;

-- Procedure 5: Issue Prescription from Medical Record
DELIMITER $$

CREATE PROCEDURE sp_IssuePrescription(
    IN p_AppointmentID INT,
    IN p_DoctorID INT,
    IN p_PatientID INT,
    IN p_MedicationID INT,
    IN p_Dosage VARCHAR(50),
    IN p_Frequency VARCHAR(50),
    IN p_Duration INT,
    IN p_DurationUnit VARCHAR(20),
    IN p_Instructions TEXT,
    OUT p_PrescriptionID INT,
    OUT p_Message VARCHAR(300)
)
BEGIN
    DECLARE v_MedicationExists INT;
    DECLARE v_DoctorExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_Message = 'Error: Failed to issue prescription.';
        SET p_PrescriptionID = -1;
    END;
    
    -- Validate medication and doctor exist
    SELECT COUNT(*) INTO v_MedicationExists FROM Medications WHERE MedicationID = p_MedicationID;
    SELECT COUNT(*) INTO v_DoctorExists FROM Doctors WHERE DoctorID = p_DoctorID;
    
    IF v_MedicationExists = 0 OR v_DoctorExists = 0 THEN
        SET p_Message = 'Error: Invalid medication or doctor.';
        SET p_PrescriptionID = -1;
    ELSE
        INSERT INTO Prescriptions (AppointmentID, DoctorID, PatientID, MedicationID, Dosage, Frequency, Duration, DurationUnit, StartDate, Instructions)
        VALUES (p_AppointmentID, p_DoctorID, p_PatientID, p_MedicationID, p_Dosage, p_Frequency, p_Duration, p_DurationUnit, CURDATE(), p_Instructions);
        
        SET p_PrescriptionID = LAST_INSERT_ID();
        SET p_Message = CONCAT('Success: Prescription issued with ID ', p_PrescriptionID);
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function 1: Calculate Patient Age
DELIMITER $$

CREATE FUNCTION fn_GetPatientAge(p_DateOfBirth DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_Age INT;
    SET v_Age = YEAR(CURDATE()) - YEAR(p_DateOfBirth) - 
                (CASE WHEN MONTH(CURDATE()) * 100 + DAY(CURDATE()) < MONTH(p_DateOfBirth) * 100 + DAY(p_DateOfBirth) 
                      THEN 1 ELSE 0 END);
    RETURN v_Age;
END$$

DELIMITER ;

-- Function 2: Determine Lab Result Status
DELIMITER $$

CREATE FUNCTION fn_GetLabResultStatus(p_TestValue DECIMAL(10, 4), p_NormalMin DECIMAL(10, 2), p_NormalMax DECIMAL(10, 2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_TestValue < p_NormalMin * 0.5 OR p_TestValue > p_NormalMax * 1.5 THEN
        RETURN 'Critical';
    ELSEIF p_TestValue < p_NormalMin OR p_TestValue > p_NormalMax THEN
        RETURN 'Abnormal';
    ELSE
        RETURN 'Normal';
    END IF;
END$$

DELIMITER ;

-- Function 3: Check Appointment Availability
DELIMITER $$

CREATE FUNCTION fn_IsDoctorAvailable(p_DoctorID INT, p_AppointmentDate DATETIME)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ConflictCount INT;
    SELECT COUNT(*) INTO v_ConflictCount
    FROM Appointments
    WHERE DoctorID = p_DoctorID
      AND Status IN ('Scheduled', 'Completed')
      AND ABS(TIMESTAMPDIFF(MINUTE, AppointmentDate, p_AppointmentDate)) < 30;
    
    RETURN (v_ConflictCount = 0);
END$$

DELIMITER ;

-- Function 4: Calculate Days Until Prescription Expiry
DELIMITER $$

CREATE FUNCTION fn_GetPrescriptionDaysRemaining(p_StartDate DATE, p_Duration INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_EndDate DATE;
    SET v_EndDate = DATE_ADD(p_StartDate, INTERVAL p_Duration DAY);
    RETURN DATEDIFF(v_EndDate, CURDATE());
END$$

DELIMITER ;

-- Function 5: Get Patient Risk Score
DELIMITER $$

CREATE FUNCTION fn_GetPatientRiskScore(p_PatientID INT)
RETURNS DECIMAL(5, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_RiskScore DECIMAL(5, 2) DEFAULT 0;
    DECLARE v_AbnormalLabCount INT;
    DECLARE v_DiagnosisCount INT;
    DECLARE v_Age INT;
    DECLARE v_DateOfBirth DATE;
    
    -- Get patient age
    SELECT DateOfBirth INTO v_DateOfBirth FROM Patients WHERE PatientID = p_PatientID;
    SET v_Age = fn_GetPatientAge(v_DateOfBirth);
    
    -- Count abnormal labs
    SELECT COUNT(*) INTO v_AbnormalLabCount
    FROM LabResults
    WHERE PatientID = p_PatientID AND Status IN ('Abnormal', 'Critical');
    
    -- Count diagnoses
    SELECT COUNT(*) INTO v_DiagnosisCount
    FROM MedicalRecords
    WHERE PatientID = p_PatientID;
    
    -- Calculate risk score
    SET v_RiskScore = (v_AbnormalLabCount * 10) + (v_DiagnosisCount * 15);
    
    -- Age factor (higher risk for elderly)
    IF v_Age > 65 THEN
        SET v_RiskScore = v_RiskScore + 20;
    ELSEIF v_Age > 50 THEN
        SET v_RiskScore = v_RiskScore + 10;
    END IF;
    
    RETURN v_RiskScore;
END$$

DELIMITER ;
