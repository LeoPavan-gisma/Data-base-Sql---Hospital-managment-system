-- Hospital Management System - Database Schema
-- SQL Implementation for M605 Advanced Databases
-- Created: March 2026

CREATE DATABASE IF NOT EXISTS HospitalManagement;
USE HospitalManagement;

-- Table 1: Departments
CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    HeadOfDepartment VARCHAR(100),
    Location VARCHAR(100),
    Budget DECIMAL(12, 2),
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: Doctors (Healthcare Professionals)
CREATE TABLE Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    LicenseNumber VARCHAR(20) UNIQUE NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    DepartmentID INT,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    YearsOfExperience INT,
    Qualifications TEXT,
    AvailabilityStatus ENUM('Available', 'On Leave', 'Retired') DEFAULT 'Available',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    INDEX idx_specialization (Specialization),
    INDEX idx_availability (AvailabilityStatus)
);

-- Table 3: Patients
CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    BloodType VARCHAR(3) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255),
    EmergencyContact VARCHAR(20),
    PreexistingConditions TEXT,
    Allergies TEXT,
    InsuranceProvider VARCHAR(100),
    InsurancePolicyNumber VARCHAR(50),
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bloodtype (BloodType),
    INDEX idx_registration (RegistrationDate)
);

-- Table 4: Appointments
CREATE TABLE Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    EndTime DATETIME,
    ReasonForVisit VARCHAR(255) NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    Notes TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    INDEX idx_date (AppointmentDate),
    INDEX idx_status (Status),
    INDEX idx_patient (PatientID)
);

-- Table 5: Lab Tests
CREATE TABLE LabTests (
    LabTestID INT AUTO_INCREMENT PRIMARY KEY,
    TestName VARCHAR(100) NOT NULL,
    TestCode VARCHAR(20) UNIQUE NOT NULL,
    NormalRangeMin DECIMAL(10, 2),
    NormalRangeMax DECIMAL(10, 2),
    Unit VARCHAR(50),
    Description TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_testname (TestName)
);

-- Table 6: Lab Results
CREATE TABLE LabResults (
    LabResultID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    LabTestID INT NOT NULL,
    TestValue DECIMAL(10, 4) NOT NULL,
    Status ENUM('Normal', 'Abnormal', 'Critical') DEFAULT 'Normal',
    ResultDate DATETIME NOT NULL,
    TechnicianNotes TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (LabTestID) REFERENCES LabTests(LabTestID),
    INDEX idx_patient (PatientID),
    INDEX idx_status (Status),
    INDEX idx_resultdate (ResultDate)
);

-- Table 7: Medications
CREATE TABLE Medications (
    MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    MedicationName VARCHAR(100) NOT NULL,
    ActiveIngredient VARCHAR(100) NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    SideEffects TEXT,
    Contraindications TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (MedicationName)
);

-- Table 8: Prescriptions
CREATE TABLE Prescriptions (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    DoctorID INT NOT NULL,
    PatientID INT NOT NULL,
    MedicationID INT NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    Duration INT NOT NULL,
    DurationUnit ENUM('Days', 'Weeks', 'Months') DEFAULT 'Days',
    StartDate DATE NOT NULL,
    Instructions TEXT,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID),
    INDEX idx_patient (PatientID),
    INDEX idx_startdate (StartDate)
);

-- Table 9: Medical Records
CREATE TABLE MedicalRecords (
    RecordID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentID INT NOT NULL,
    Diagnosis VARCHAR(255) NOT NULL,
    TreatmentPlan TEXT,
    ClinicalNotes TEXT,
    RecordDate DATETIME NOT NULL,
    Status ENUM('Draft', 'Finalized', 'Archived') DEFAULT 'Draft',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LastModified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    INDEX idx_patient (PatientID),
    INDEX idx_date (RecordDate)
);

-- Table 10: Billing
CREATE TABLE Billing (
    BillingID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    AppointmentID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    ServiceDescription VARCHAR(255),
    BillingDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    PaidDate DATE,
    Status ENUM('Pending', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Pending',
    PaymentMethod VARCHAR(50),
    InsuranceCovered DECIMAL(10, 2),
    PatientResponsibility DECIMAL(10, 2),
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    INDEX idx_status (Status),
    INDEX idx_billingdate (BillingDate)
);

-- Table 11: Hospital Inventory
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    ItemType VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    MinimumQuantity INT NOT NULL,
    Unit VARCHAR(20),
    Location VARCHAR(100),
    Vendor VARCHAR(100),
    LastRestockedDate DATE,
    ExpiryDate DATE,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_itemtype (ItemType),
    INDEX idx_quantity (Quantity)
);

-- Table 12: Staff (Additional healthcare workers)
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    StaffType ENUM('Nurse', 'Technician', 'Administrator', 'Cleaner') NOT NULL,
    DepartmentID INT,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    HireDate DATE NOT NULL,
    Status ENUM('Active', 'On Leave', 'Terminated') DEFAULT 'Active',
    Shift VARCHAR(50),
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    INDEX idx_stafftype (StaffType)
);
