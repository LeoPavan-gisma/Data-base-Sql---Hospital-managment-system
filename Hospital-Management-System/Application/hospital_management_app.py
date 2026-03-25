#!/usr/bin/env python3
"""
Hospital Management System - Main Application
M605 Advanced Databases - Hybrid SQL/NoSQL Integration
"""

import sqlite3
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple

class HospitalDatabase:
    """SQLite-based Hospital Management System for Development and Testing"""
    
    def __init__(self, db_path: str = "hospital_system.db"):
        """Initialize database connection"""
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()
        print(f"Connected to SQLite database: {db_path}")
    
    def create_schema(self):
        """Create all database tables"""
        schema = """
        -- Departments
        CREATE TABLE IF NOT EXISTS Departments (
            DepartmentID INTEGER PRIMARY KEY AUTOINCREMENT,
            DepartmentName TEXT UNIQUE NOT NULL,
            Budget REAL,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Doctors
        CREATE TABLE IF NOT EXISTS Doctors (
            DoctorID INTEGER PRIMARY KEY AUTOINCREMENT,
            LicenseNumber TEXT UNIQUE NOT NULL,
            FirstName TEXT NOT NULL,
            LastName TEXT NOT NULL,
            DepartmentID INTEGER,
            Specialization TEXT,
            YearsOfExperience INTEGER,
            Email TEXT UNIQUE,
            Phone TEXT,
            AvailabilityStatus TEXT DEFAULT 'Available',
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
        );
        
        -- Patients
        CREATE TABLE IF NOT EXISTS Patients (
            PatientID INTEGER PRIMARY KEY AUTOINCREMENT,
            FirstName TEXT NOT NULL,
            LastName TEXT NOT NULL,
            DateOfBirth DATE NOT NULL,
            Gender TEXT,
            Email TEXT UNIQUE,
            Phone TEXT,
            BloodType TEXT,
            Address TEXT,
            InsuranceProvider TEXT,
            PolicyNumber TEXT,
            PreexistingConditions TEXT,
            Allergies TEXT,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Appointments
        CREATE TABLE IF NOT EXISTS Appointments (
            AppointmentID INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientID INTEGER NOT NULL,
            DoctorID INTEGER NOT NULL,
            AppointmentDate TIMESTAMP NOT NULL,
            AppointmentTime TEXT,
            ReasonForVisit TEXT,
            AppointmentStatus TEXT DEFAULT 'Scheduled',
            Notes TEXT,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
            FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
        );
        
        -- Lab Tests
        CREATE TABLE IF NOT EXISTS LabTests (
            LabTestID INTEGER PRIMARY KEY AUTOINCREMENT,
            LabTestName TEXT UNIQUE NOT NULL,
            NormalRange TEXT,
            Unit TEXT,
            Description TEXT
        );
        
        -- Lab Results
        CREATE TABLE IF NOT EXISTS LabResults (
            LabResultID INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientID INTEGER NOT NULL,
            LabTestID INTEGER NOT NULL,
            DoctorID INTEGER,
            TestResult TEXT NOT NULL,
            TestDate DATE NOT NULL,
            IsAbnormal BOOLEAN DEFAULT 0,
            IsCritical BOOLEAN DEFAULT 0,
            Interpretation TEXT,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
            FOREIGN KEY (LabTestID) REFERENCES LabTests(LabTestID),
            FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
        );
        
        -- Medications
        CREATE TABLE IF NOT EXISTS Medications (
            MedicationID INTEGER PRIMARY KEY AUTOINCREMENT,
            MedicationName TEXT UNIQUE NOT NULL,
            ActiveIngredient TEXT,
            Dosage TEXT,
            Form TEXT,
            Manufacturer TEXT,
            SideEffects TEXT,
            Contraindications TEXT,
            Price REAL
        );
        
        -- Prescriptions
        CREATE TABLE IF NOT EXISTS Prescriptions (
            PrescriptionID INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientID INTEGER NOT NULL,
            MedicationID INTEGER NOT NULL,
            DoctorID INTEGER NOT NULL,
            Dosage TEXT,
            Frequency TEXT,
            StartDate DATE,
            EndDate DATE,
            Refills INTEGER,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
            FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID),
            FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
        );
        
        -- Medical Records
        CREATE TABLE IF NOT EXISTS MedicalRecords (
            MedicalRecordID INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientID INTEGER NOT NULL,
            AppointmentID INTEGER,
            DoctorID INTEGER NOT NULL,
            Diagnosis TEXT,
            Symptoms TEXT,
            TreatmentPlan TEXT,
            ClinicalNotes TEXT,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            LastModified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
            FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
            FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
        );
        
        -- Billing
        CREATE TABLE IF NOT EXISTS Billing (
            BillingID INTEGER PRIMARY KEY AUTOINCREMENT,
            PatientID INTEGER NOT NULL,
            AppointmentID INTEGER,
            DepartmentID INTEGER,
            Amount REAL,
            PaymentStatus TEXT DEFAULT 'Pending',
            PaymentDate DATE,
            InsuranceCoverage REAL,
            CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
            FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
            FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
        );
        
        -- Create indices for performance
        CREATE INDEX IF NOT EXISTS idx_patient_email ON Patients(Email);
        CREATE INDEX IF NOT EXISTS idx_doctor_specialization ON Doctors(Specialization);
        CREATE INDEX IF NOT EXISTS idx_appointment_date ON Appointments(AppointmentDate);
        CREATE INDEX IF NOT EXISTS idx_appointment_status ON Appointments(AppointmentStatus);
        CREATE INDEX IF NOT EXISTS idx_lab_result_date ON LabResults(TestDate);
        CREATE INDEX IF NOT EXISTS idx_lab_result_abnormal ON LabResults(IsAbnormal);
        CREATE INDEX IF NOT EXISTS idx_billing_status ON Billing(PaymentStatus);
        """
        
        for statement in schema.split(';'):
            if statement.strip():
                self.cursor.execute(statement)
        
        self.conn.commit()
        print("Database schema created successfully")
    
    def insert_sample_data(self):
        """Insert sample healthcare data"""
        
        # Departments
        departments = [
            ("Cardiology", 600000),
            ("Pediatrics", 500000),
            ("Orthopedics", 550000),
            ("Neurology", 600000),
            ("Emergency", 700000),
            ("Surgery", 650000),
            ("Psychiatry", 450000),
            ("Radiology", 500000),
        ]
        
        for dept_name, budget in departments:
            self.cursor.execute(
                "INSERT OR IGNORE INTO Departments (DepartmentName, Budget) VALUES (?, ?)",
                (dept_name, budget)
            )
        
        # Doctors
        doctors = [
            ("LIC001", "Ahmed", "Ali", 1, "Cardiology", 15, "ahmed.ali@hospital.com", "050-1234567"),
            ("LIC002", "Fatima", "Hassan", 2, "Pediatrics", 12, "fatima.hassan@hospital.com", "050-2345678"),
            ("LIC003", "Mohammed", "Ibrahim", 3, "Orthopedics", 10, "mohammed.ibrahim@hospital.com", "050-3456789"),
            ("LIC004", "Noor", "Ahmed", 4, "Neurology", 18, "noor.ahmed@hospital.com", "050-4567890"),
            ("LIC005", "Layla", "Mohamed", 1, "Cardiology", 14, "layla.mohamed@hospital.com", "050-5678901"),
        ]
        
        for license, fname, lname, dept, spec, years, email, phone in doctors:
            self.cursor.execute(
                """INSERT OR IGNORE INTO Doctors 
                (LicenseNumber, FirstName, LastName, DepartmentID, Specialization, YearsOfExperience, Email, Phone)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (license, fname, lname, dept, spec, years, email, phone)
            )
        
        # Patients
        patients = [
            ("John", "Smith", "1980-03-15", "Male", "john@example.com", "050-9876543", "O+", "123 Main St", "InsureCorp", "POL001", "Hypertension", "Penicillin"),
            ("Sarah", "Johnson", "1990-07-22", "Female", "sarah@example.com", "050-8765432", "A+", "456 Oak Ave", "HealthPlus", "POL002", "Diabetes", "Aspirin"),
            ("Mohammed", "Ahmed", "1975-01-10", "Male", "mohammed@example.com", "050-7654321", "B+", "789 Pine Rd", "GoldHealth", "POL003", "Asthma", "Iodine"),
            ("Amira", "Hassan", "1985-05-18", "Female", "amira@example.com", "050-6543210", "AB+", "321 Elm St", "InsureCorp", "POL004", "None", "Shellfish"),
            ("David", "Brown", "1992-09-30", "Male", "david@example.com", "050-5432109", "O-", "654 Maple Dr", "HealthPlus", "POL005", "Arthritis", "None"),
        ]
        
        for fname, lname, dob, gender, email, phone, blood, addr, insur, policy, conditions, allergies in patients:
            self.cursor.execute(
                """INSERT OR IGNORE INTO Patients
                (FirstName, LastName, DateOfBirth, Gender, Email, Phone, BloodType, Address, InsuranceProvider, PolicyNumber, PreexistingConditions, Allergies)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (fname, lname, dob, gender, email, phone, blood, addr, insur, policy, conditions, allergies)
            )
        
        # Lab Tests
        lab_tests = [
            ("Blood Count", "4.5-5.5 M/uL", "M/uL", "Complete Blood Count"),
            ("Glucose", "70-100 mg/dL", "mg/dL", "Fasting Blood Glucose"),
            ("Cholesterol", "<200 mg/dL", "mg/dL", "Total Cholesterol"),
            ("Triglycerides", "<150 mg/dL", "mg/dL", "Blood Triglycerides"),
            ("Creatinine", "0.6-1.2 mg/dL", "mg/dL", "Kidney Function"),
        ]
        
        for test_name, range_val, unit, desc in lab_tests:
            self.cursor.execute(
                "INSERT OR IGNORE INTO LabTests (LabTestName, NormalRange, Unit, Description) VALUES (?, ?, ?, ?)",
                (test_name, range_val, unit, desc)
            )
        
        # Medications
        medications = [
            ("Lisinopril", "Lisinopril", "10mg", "Tablet", "Pfizer", "Dizziness, cough", "Pregnancy"),
            ("Metformin", "Metformin", "500mg", "Tablet", "Hospira", "Nausea, diarrhea", "Renal disease"),
            ("Aspirin", "Acetylsalicylic Acid", "75mg", "Tablet", "Bayer", "Bleeding risk", "Aspirin allergy"),
            ("Amoxicillin", "Amoxicillin", "500mg", "Capsule", "GlaxoSmithKline", "Rash, nausea", "Penicillin allergy"),
            ("Ibuprofen", "Ibuprofen", "400mg", "Tablet", "Nurofen", "Stomach upset", "NSAID allergy"),
        ]
        
        for med_name, active, dosage, form, manu, side_effects, contra in medications:
            self.cursor.execute(
                """INSERT OR IGNORE INTO Medications
                (MedicationName, ActiveIngredient, Dosage, Form, Manufacturer, SideEffects, Contraindications)
                VALUES (?, ?, ?, ?, ?, ?, ?)""",
                (med_name, active, dosage, form, manu, side_effects, contra)
            )
        
        self.conn.commit()
        print("Sample data inserted successfully")
    
    # ========== CRUD OPERATIONS ==========
    
    def add_patient(self, fname: str, lname: str, dob: str, gender: str, email: str, 
                   phone: str, blood_type: str, address: str, insurance: str, 
                   policy: str) -> int:
        """Add new patient"""
        self.cursor.execute(
            """INSERT INTO Patients 
            (FirstName, LastName, DateOfBirth, Gender, Email, Phone, BloodType, Address, InsuranceProvider, PolicyNumber)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (fname, lname, dob, gender, email, phone, blood_type, address, insurance, policy)
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_patient(self, patient_id: int) -> Optional[Dict]:
        """Get patient details"""
        self.cursor.execute("SELECT * FROM Patients WHERE PatientID = ?", (patient_id,))
        row = self.cursor.fetchone()
        return dict(row) if row else None
    
    def update_patient(self, patient_id: int, **kwargs) -> bool:
        """Update patient information"""
        valid_fields = ['Email', 'Phone', 'Address', 'PreexistingConditions', 'Allergies']
        fields = [f"{k} = ?" for k in kwargs.keys() if k in valid_fields]
        
        if not fields:
            return False
        
        values = [kwargs[k] for k in kwargs.keys() if k in valid_fields]
        values.append(patient_id)
        
        query = f"UPDATE Patients SET {', '.join(fields)}, UpdatedAt = CURRENT_TIMESTAMP WHERE PatientID = ?"
        self.cursor.execute(query, values)
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    def delete_patient(self, patient_id: int) -> bool:
        """Delete patient (soft delete)"""
        # In real system, would archive rather than delete
        self.cursor.execute("DELETE FROM Patients WHERE PatientID = ?", (patient_id,))
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    # ========== APPOINTMENT OPERATIONS ==========
    
    def schedule_appointment(self, patient_id: int, doctor_id: int, 
                            appointment_date: str, appointment_time: str, reason: str) -> int:
        """Schedule new appointment"""
        self.cursor.execute(
            """INSERT INTO Appointments 
            (PatientID, DoctorID, AppointmentDate, AppointmentTime, ReasonForVisit, AppointmentStatus)
            VALUES (?, ?, ?, ?, ?, 'Scheduled')""",
            (patient_id, doctor_id, appointment_date, appointment_time, reason)
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_patient_appointments(self, patient_id: int) -> List[Dict]:
        """Get all appointments for patient"""
        self.cursor.execute(
            """SELECT a.*, d.FirstName as DoctorFirstName, d.LastName as DoctorLastName, d.Specialization
            FROM Appointments a
            JOIN Doctors d ON a.DoctorID = d.DoctorID
            WHERE a.PatientID = ?
            ORDER BY a.AppointmentDate DESC""",
            (patient_id,)
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def get_doctor_schedule(self, doctor_id: int) -> List[Dict]:
        """Get doctor's appointment schedule"""
        self.cursor.execute(
            """SELECT a.*, p.FirstName as PatientFirstName, p.LastName as PatientLastName, p.Email, p.Phone
            FROM Appointments a
            JOIN Patients p ON a.PatientID = p.PatientID
            WHERE a.DoctorID = ? AND a.AppointmentStatus != 'Cancelled'
            ORDER BY a.AppointmentDate""",
            (doctor_id,)
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def update_appointment_status(self, appointment_id: int, status: str) -> bool:
        """Update appointment status"""
        valid_statuses = ['Scheduled', 'Completed', 'Cancelled', 'No-Show']
        if status not in valid_statuses:
            return False
        
        self.cursor.execute(
            "UPDATE Appointments SET AppointmentStatus = ?, UpdatedAt = CURRENT_TIMESTAMP WHERE AppointmentID = ?",
            (status, appointment_id)
        )
        self.conn.commit()
        return self.cursor.rowcount > 0
    
    # ========== LAB OPERATIONS ==========
    
    def record_lab_result(self, patient_id: int, lab_test_id: int, 
                         doctor_id: int, result: str, test_date: str) -> int:
        """Record lab result with automatic abnormality detection"""
        self.cursor.execute("SELECT * FROM LabTests WHERE LabTestID = ?", (lab_test_id,))
        test = dict(self.cursor.fetchone())
        
        # Simple abnormality detection (in production would be more sophisticated)
        is_abnormal = False
        is_critical = False
        interpretation = "Normal"
        
        try:
            result_val = float(result.split()[0])
            # Check if abnormal (simple logic)
            if result_val > 100:  # Simplified check
                is_abnormal = True
                interpretation = "Abnormal"
            if result_val > 150:  # Simplified critical check
                is_critical = True
                interpretation = "Critical"
        except:
            pass
        
        self.cursor.execute(
            """INSERT INTO LabResults
            (PatientID, LabTestID, DoctorID, TestResult, TestDate, IsAbnormal, IsCritical, Interpretation)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (patient_id, lab_test_id, doctor_id, result, test_date, is_abnormal, is_critical, interpretation)
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_patient_lab_results(self, patient_id: int, days: int = 30) -> List[Dict]:
        """Get recent lab results for patient"""
        self.cursor.execute(
            """SELECT lr.*, lt.LabTestName, lt.NormalRange
            FROM LabResults lr
            JOIN LabTests lt ON lr.LabTestID = lt.LabTestID
            WHERE lr.PatientID = ? AND lr.TestDate >= date('now', '-' || ? || ' days')
            ORDER BY lr.TestDate DESC""",
            (patient_id, days)
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    # ========== MEDICAL RECORDS OPERATIONS ==========
    
    def create_medical_record(self, patient_id: int, appointment_id: int, doctor_id: int,
                            diagnosis: str, symptoms: str, treatment_plan: str, notes: str) -> int:
        """Create medical record"""
        self.cursor.execute(
            """INSERT INTO MedicalRecords
            (PatientID, AppointmentID, DoctorID, Diagnosis, Symptoms, TreatmentPlan, ClinicalNotes)
            VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (patient_id, appointment_id, doctor_id, diagnosis, symptoms, treatment_plan, notes)
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_patient_medical_records(self, patient_id: int) -> List[Dict]:
        """Get all medical records for patient"""
        self.cursor.execute(
            """SELECT mr.*, d.FirstName as DoctorFirstName, d.LastName as DoctorLastName
            FROM MedicalRecords mr
            LEFT JOIN Doctors d ON mr.DoctorID = d.DoctorID
            WHERE mr.PatientID = ?
            ORDER BY mr.CreatedAt DESC""",
            (patient_id,)
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    # ========== PRESCRIPTION OPERATIONS ==========
    
    def issue_prescription(self, patient_id: int, medication_id: int, doctor_id: int,
                          dosage: str, frequency: str, start_date: str, end_date: str, refills: int) -> int:
        """Issue prescription"""
        self.cursor.execute(
            """INSERT INTO Prescriptions
            (PatientID, MedicationID, DoctorID, Dosage, Frequency, StartDate, EndDate, Refills)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (patient_id, medication_id, doctor_id, dosage, frequency, start_date, end_date, refills)
        )
        self.conn.commit()
        return self.cursor.lastrowid
    
    def get_patient_prescriptions(self, patient_id: int) -> List[Dict]:
        """Get active prescriptions for patient"""
        self.cursor.execute(
            """SELECT pr.*, m.MedicationName, m.SideEffects, m.Contraindications
            FROM Prescriptions pr
            JOIN Medications m ON pr.MedicationID = m.MedicationID
            WHERE pr.PatientID = ? AND pr.EndDate >= date('now')
            ORDER BY pr.StartDate DESC""",
            (patient_id,)
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    # ========== ANALYTICAL QUERIES ==========
    
    def get_high_risk_patients(self) -> List[Dict]:
        """Get patients with critical lab values"""
        self.cursor.execute(
            """SELECT DISTINCT p.PatientID, p.FirstName, p.LastName, p.Email, p.Phone,
                COUNT(DISTINCT lr.LabResultID) as CriticalCount, MAX(lr.TestDate) as LatestTest
            FROM Patients p
            JOIN LabResults lr ON p.PatientID = lr.PatientID
            WHERE lr.IsCritical = 1
            GROUP BY p.PatientID
            HAVING CriticalCount > 0
            ORDER BY CriticalCount DESC"""
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def get_doctor_workload(self) -> List[Dict]:
        """Get doctor workload analysis"""
        self.cursor.execute(
            """SELECT d.DoctorID, d.FirstName, d.LastName, d.Specialization,
                COUNT(DISTINCT a.AppointmentID) as TotalAppointments,
                SUM(CASE WHEN a.AppointmentStatus = 'Completed' THEN 1 ELSE 0 END) as Completed,
                SUM(CASE WHEN a.AppointmentStatus = 'No-Show' THEN 1 ELSE 0 END) as NoShow
            FROM Doctors d
            LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
            GROUP BY d.DoctorID
            ORDER BY TotalAppointments DESC"""
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def get_department_statistics(self) -> List[Dict]:
        """Get department statistics"""
        self.cursor.execute(
            """SELECT d.DepartmentID, d.DepartmentName, d.Budget,
                COUNT(DISTINCT doc.DoctorID) as DoctorCount,
                COUNT(DISTINCT a.AppointmentID) as TotalAppointments
            FROM Departments d
            LEFT JOIN Doctors doc ON d.DepartmentID = doc.DepartmentID
            LEFT JOIN Appointments a ON doc.DoctorID = a.DoctorID
            GROUP BY d.DepartmentID
            ORDER BY TotalAppointments DESC"""
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def get_billing_summary(self) -> List[Dict]:
        """Get billing summary by patient"""
        self.cursor.execute(
            """SELECT p.PatientID, p.FirstName, p.LastName,
                SUM(b.Amount) as TotalBilled,
                SUM(CASE WHEN b.PaymentStatus = 'Paid' THEN b.Amount ELSE 0 END) as Paid,
                SUM(CASE WHEN b.PaymentStatus = 'Pending' THEN b.Amount ELSE 0 END) as Pending,
                SUM(CASE WHEN b.PaymentStatus = 'Overdue' THEN b.Amount ELSE 0 END) as Overdue
            FROM Patients p
            LEFT JOIN Billing b ON p.PatientID = b.PatientID
            GROUP BY p.PatientID
            ORDER BY TotalBilled DESC"""
        )
        return [dict(row) for row in self.cursor.fetchall()]
    
    def close(self):
        """Close database connection"""
        self.conn.close()
        print("Database connection closed")


def demo_application():
    """Demonstrate all functionality"""
    
    print("\n" + "="*80)
    print("HOSPITAL MANAGEMENT SYSTEM - DEMONSTRATION")
    print("="*80 + "\n")
    
    # Initialize database
    db = HospitalDatabase("hospital_system.db")
    db.create_schema()
    db.insert_sample_data()
    
    print("\n" + "-"*80)
    print("1. PATIENT OPERATIONS")
    print("-"*80)
    
    # Add new patient
    print("\n→ Adding new patient...")
    new_patient_id = db.add_patient(
        "Emma", "Wilson", "1988-06-14", "Female", "emma.wilson@example.com",
        "050-1111111", "A+", "999 Hospital Lane", "InsureCorp", "POL006"
    )
    print(f"  New patient ID: {new_patient_id}")
    
    # Get patient details
    print(f"\n→ Retrieving patient details for ID {new_patient_id}...")
    patient = db.get_patient(new_patient_id)
    print(f"  Patient: {patient['FirstName']} {patient['LastName']}")
    print(f"  Email: {patient['Email']}, Phone: {patient['Phone']}")
    print(f"  Blood Type: {patient['BloodType']}, DOB: {patient['DateOfBirth']}")
    
    # Update patient
    print(f"\n→ Updating patient contact information...")
    db.update_patient(new_patient_id, Phone="050-9999999", Email="emma.new@example.com")
    print(f"  Contact updated successfully")
    
    print("\n" + "-"*80)
    print("2. APPOINTMENT OPERATIONS")
    print("-"*80)
    
    # Schedule appointment
    print("\n→ Scheduling appointment...")
    appt_id = db.schedule_appointment(
        patient_id=1, doctor_id=1, 
        appointment_date="2026-03-25 10:00", 
        appointment_time="10:00 AM",
        reason="Routine checkup"
    )
    print(f"  Appointment ID: {appt_id}")
    
    # Get patient appointments
    print(f"\n→ Patient appointment history...")
    appointments = db.get_patient_appointments(1)
    for appt in appointments[:3]:
        print(f"  - {appt['AppointmentDate']} with Dr. {appt['DoctorFirstName']} {appt['DoctorLastName']}")
        print(f"    Reason: {appt['ReasonForVisit']} | Status: {appt['AppointmentStatus']}")
    
    # Get doctor schedule
    print(f"\n→ Doctor appointment schedule...")
    schedule = db.get_doctor_schedule(1)
    for appt in schedule[:2]:
        print(f"  - {appt['AppointmentDate']} with {appt['PatientFirstName']} {appt['PatientLastName']}")
    
    print("\n" + "-"*80)
    print("3. LABORATORY OPERATIONS")
    print("-"*80)
    
    # Record lab results
    print("\n→ Recording lab results...")
    lab_result_id = db.record_lab_result(
        patient_id=1, lab_test_id=2, doctor_id=1,
        result="115 mg/dL", test_date="2026-03-20"
    )
    print(f"  Lab Result ID: {lab_result_id}")
    
    # Get patient lab results
    print(f"\n→ Patient recent lab results...")
    results = db.get_patient_lab_results(1)
    for result in results[:3]:
        status = "CRITICAL" if result['IsCritical'] else ("ABNORMAL" if result['IsAbnormal'] else "NORMAL")
        print(f"  - {result['LabTestName']}: {result['TestResult']} ({result['NormalRange']})")
        print(f"    Date: {result['TestDate']} | Status: {status}")
    
    print("\n" + "-"*80)
    print("4. MEDICAL RECORDS")
    print("-"*80)
    
    # Create medical record
    print("\n→ Creating medical record...")
    record_id = db.create_medical_record(
        patient_id=1, appointment_id=1, doctor_id=1,
        diagnosis="Hypertension",
        symptoms="Elevated blood pressure, occasional headaches",
        treatment_plan="Continue medication, reduce salt intake, exercise 30 min daily",
        notes="Patient compliant with current medication. BP improved from 160/95 to 145/88"
    )
    print(f"  Medical Record ID: {record_id}")
    
    # Get patient medical records
    print(f"\n→ Patient medical history...")
    records = db.get_patient_medical_records(1)
    for record in records[:2]:
        print(f"  - Date: {record['CreatedAt']}")
        print(f"    Diagnosis: {record['Diagnosis']}")
        print(f"    Doctor: Dr. {record['DoctorFirstName']} {record['DoctorLastName']}")
    
    print("\n" + "-"*80)
    print("5. PRESCRIPTION MANAGEMENT")
    print("-"*80)
    
    # Issue prescription
    print("\n→ Issuing prescription...")
    rx_id = db.issue_prescription(
        patient_id=1, medication_id=1, doctor_id=1,
        dosage="10mg", frequency="Once daily",
        start_date="2026-03-15", end_date="2026-09-15", refills=3
    )
    print(f"  Prescription ID: {rx_id}")
    
    # Get patient prescriptions
    print(f"\n→ Patient active prescriptions...")
    prescriptions = db.get_patient_prescriptions(1)
    for rx in prescriptions[:3]:
        print(f"  - {rx['MedicationName']} {rx['Dosage']} {rx['Frequency']}")
        print(f"    From: {rx['StartDate']} To: {rx['EndDate']}")
    
    print("\n" + "-"*80)
    print("6. ANALYTICAL REPORTS")
    print("-"*80)
    
    # High-risk patients
    print("\n→ High-risk patients (critical lab values):")
    high_risk = db.get_high_risk_patients()
    for patient in high_risk[:3]:
        print(f"  - {patient['FirstName']} {patient['LastName']} ({patient['CriticalCount']} critical tests)")
        print(f"    Email: {patient['Email']} | Phone: {patient['Phone']}")
    
    if not high_risk:
        print("  (No patients with critical values)")
    
    # Doctor workload
    print("\n→ Doctor workload analysis:")
    workload = db.get_doctor_workload()
    for doctor in workload[:3]:
        print(f"  - Dr. {doctor['FirstName']} {doctor['LastName']} ({doctor['Specialization']})")
        print(f"    Total Appointments: {doctor['TotalAppointments']} | Completed: {doctor['Completed']} | No-Show: {doctor['NoShow']}")
    
    # Department statistics
    print("\n→ Department statistics:")
    departments = db.get_department_statistics()
    for dept in departments[:3]:
        print(f"  - {dept['DepartmentName']}: {dept['DoctorCount']} doctors, {dept['TotalAppointments']} appointments")
        print(f"    Budget: AED {dept['Budget']:,.0f}")
    
    # Billing summary
    print("\n→ Billing summary (top 3):")
    billing = db.get_billing_summary()
    for bill in billing[:3]:
        if bill.get('TotalBilled'):
            print(f"  - {bill['FirstName']} {bill['LastName']}")
            print(f"    Total Billed: AED {bill['TotalBilled']:,.0f} | Paid: AED {bill['Paid'] or 0:,.0f} | Pending: AED {bill['Pending'] or 0:,.0f}")
    
    print("\n" + "="*80)
    print("DEMONSTRATION COMPLETE")
    print("="*80 + "\n")
    
    db.close()


if __name__ == "__main__":
    demo_application()
