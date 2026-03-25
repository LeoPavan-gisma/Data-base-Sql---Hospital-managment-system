# Hospital Management System - Entity Relationship Diagram

## Database Design Overview

This Hospital Management System uses a **hybrid SQL/NoSQL architecture** to handle both structured (relational) and unstructured (document-based) healthcare data. The design follows **3rd Normal Form (3NF)** normalization principles with ACID compliance for critical operations.

### Design Principles Applied:
1. **Normalization** - Eliminated redundancy through 3NF design
2. **Referential Integrity** - Foreign keys maintain data consistency
3. **ACID Compliance** - Transactions, rollback support, consistency checks
4. **Scalability** - Efficient indexing for large datasets
5. **Auditability** - Timestamps and activity logging for compliance
6. **Data Security** - Encryption-ready fields for sensitive data

---

```
                          ┌─────────────────────┐
                          │    DEPARTMENTS      │
                          ├─────────────────────┤
                          │ DepartmentID (PK)   │
                          │ DepartmentName      │
                          │ Budget              │
                          │ HeadDoctorID (FK)   │
                          │ ContactNumber       │
                          │ Location            │
                          │ CreatedAt           │
                          │ UpdatedAt           │
                          └──────────┬──────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    │                │                │
        ┌───────────▼──────────┐    │    ┌───────────▼──────────┐
        │      DOCTORS         │    │    │       STAFF          │
        ├─────────────────────┤    │    ├─────────────────────┤
        │ DoctorID (PK)       │    │    │ StaffID (PK)        │
        │ LicenseNumber       │    │    │ FirstName           │
        │ FirstName           │    │    │ LastName            │
        │ LastName            │    │    │ Position            │
        │ DepartmentID (FK)───┼────┤    │ DepartmentID (FK)───┼──────┐
        │ Specialization      │    │    │ Email               │      │
        │ YearsOfExperience   │    │    │ Phone               │      │
        │ AvailabilityStatus  │    │    │ HireDate            │      │
        │ Email               │    │    │ Salary              │      │
        │ Phone               │    │    │ CreatedAt           │      │
        │ Qualifications      │    │    │ UpdatedAt           │      │
        │ CreatedAt           │    │    └─────────────────────┘      │
        │ UpdatedAt           │    │                                  │
        └─────────┬───────────┘    │                                  │
                  │                │                                  │
        ┌─────────┴──────────┐     │                                  │
        │                    │     │                                  │
        │                    │     │                                  │
   ┌────▼────────────────┐  │  ┌──▼──────────────────────────────┐   │
   │  APPOINTMENTS       │  │  │      PATIENTS                  │   │
   ├────────────────────┤  │  ├───────────────────────────────┤   │
   │ AppointmentID (PK) │  │  │ PatientID (PK)                │   │
   │ PatientID (FK)─────┼──┼──┼─ FirstName                    │   │
   │ DoctorID (FK)──────┼──┼─┐│ LastName                      │   │
   │ AppointmentDate    │  │ ││ DateOfBirth                   │   │
   │ AppointmentTime    │  │ ││ Gender                        │   │
   │ ReasonForVisit     │  │ ││ Email                         │   │
   │ AppointmentStatus  │  │ ││ Phone                         │   │
   │ Notes              │  │ ││ BloodType                     │   │
   │ CreatedAt          │  │ ││ Address                       │   │
   │ UpdatedAt          │  │ ││ InsuranceProvider             │   │
   └────────┬───────────┘  │ ││ PolicyNumber                  │   │
            │              │ ││ PreexistingConditions         │   │
            │              │ ││ Allergies                     │   │
            │              │ ││ IsActive                      │   │
            │              │ ││ CreatedAt                     │   │
            │              │ ││ UpdatedAt                     │   │
            │              │ └┼────────────────────────────────┤   │
            │              │  │                               │   │
            │              └──┤ ◄─ Relationship 1:N           │   │
            │                 │    (One patient, many appts)  │   │
            │                 └───────────────────────────────┘   │
            │                                                      │
            │                                                      │
    ┌───────┴──────────┐                                          │
    │                  │                                          │
    │    ┌─────────────▼──────────────────┐                      │
    │    │   MEDICAL RECORDS              │                      │
    │    ├────────────────────────────────┤                      │
    │    │ MedicalRecordID (PK)           │                      │
    │    │ AppointmentID (FK)─────────────┼─────────┐            │
    │    │ PatientID (FK)─────────────────┼──┬──────┼────────┐   │
    │    │ Diagnosis                      │  │      │        │   │
    │    │ Symptoms                       │  │      │        │   │
    │    │ TreatmentPlan                  │  │      │        │   │
    │    │ ClinicalNotes                  │  │      │        │   │
    │    │ DoctorID (FK)──────────────────┼──┼──────┼────────┼───┼┐
    │    │ CreatedAt                      │  │      │        │   ││
    │    │ LastModified                   │  │      │        │   ││
    │    └────────────────────────────────┘  │      │        │   ││
    │                                         │      │        │   ││
    │    ┌────────────────────────────────┐  │      │        │   ││
    │    │    LAB RESULTS                 │  │      │        │   ││
    │    ├────────────────────────────────┤  │      │        │   ││
    │    │ LabResultID (PK)               │  │      │        │   ││
    │    │ PatientID (FK)─────────────────┼──┼──┐  │        │   ││
    │    │ LabTestID (FK)─────────────────┼┐ │  │  │        │   ││
    │    │ DoctorID (FK)──────────────────┼┼─┼──┼──┼────┐   │   ││
    │    │ TestResult                     ││ │  │  │    │   │   ││
    │    │ TestDate                       ││ │  │  │    │   │   ││
    │    │ IsAbnormal                     ││ │  │  │    │   │   ││
    │    │ IsCritical                     ││ │  │  │    │   │   ││
    │    │ Interpretation                 ││ │  │  │    │   │   ││
    │    │ CreatedAt                      ││ │  │  │    │   │   ││
    │    │ UpdatedAt                      ││ │  │  │    │   │   ││
    │    └────────────────────────────────┘│ │  │  │    │   │   ││
    │                                        │ │  │  │    │   │   ││
    │    ┌────────────────────────────────┐ │ │  │  │    │   │   ││
    │    │    LAB TESTS                   │ │ │  │  │    │   │   ││
    │    ├────────────────────────────────┤ │ │  │  │    │   │   ││
    │    │ LabTestID (PK)─────────────────┼─┘ │  │  │    │   │   ││
    │    │ LabTestName                    │   │  │  │    │   │   ││
    │    │ NormalRange                    │   │  │  │    │   │   ││
    │    │ Unit                           │   │  │  │    │   │   ││
    │    │ Description                    │   │  │  │    │   │   ││
    │    │ CreatedAt                      │   │  │  │    │   │   ││
    │    │ UpdatedAt                      │   │  │  │    │   │   ││
    │    └────────────────────────────────┘   │  │  │    │   │   ││
    │                                          │  │  │    │   │   ││
    └──────────┬───────────────────────────────┼──┼──┼────┼───┼───┼┤
               │                              │  │  │    │   │   ││
               │    ┌────────────────────────┐│  │  │    │   │   ││
               │    │   PRESCRIPTIONS        ││  │  │    │   │   ││
               │    ├────────────────────────┤│  │  │    │   │   ││
               │    │ PrescriptionID (PK)    ││  │  │    │   │   ││
               │    │ PatientID (FK)─────────┼┼──┘  │    │   │   ││
               │    │ MedicationID (FK)──────┼┼─────┼────┤   │   ││
               │    │ DoctorID (FK)──────────┼┼─────┼────┼───┘   ││
               │    │ Dosage                 ││     │    │       ││
               │    │ Frequency              ││     │    │       ││
               │    │ StartDate              ││     │    │       ││
               │    │ EndDate                ││     │    │       ││
               │    │ Refills                ││     │    │       ││
               │    │ CreatedAt              ││     │    │       ││
               │    │ UpdatedAt              ││     │    │       ││
               │    └────────────────────────┘│     │    │       ││
               │                              │     │    │       ││
               │     ┌──────────────────────┐ │     │    │       ││
               │     │   MEDICATIONS        │ │     │    │       ││
               │     ├──────────────────────┤ │     │    │       ││
               │     │ MedicationID (PK)───┼─┼─────┴────┘       ││
               │     │ MedicationName       │ │                  ││
               │     │ ActiveIngredient     │ │                  ││
               │     │ Dosage               │ │                  ││
               │     │ Form                 │ │                  ││
               │     │ Manufacturer         │ │                  ││
               │     │ SideEffects          │ │                  ││
               │     │ Contraindications    │ │                  ││
               │     │ Price                │ │                  ││
               │     │ CreatedAt            │ │                  ││
               │     │ UpdatedAt            │ │                  ││
               │     └──────────────────────┘ │                  ││
               │                              │                  ││
               │      ┌──────────────────────┐│                  ││
               │      │    BILLING           ││                  ││
               │      ├──────────────────────┤│                  ││
               │      │ BillingID (PK)       ││                  ││
               │      │ PatientID (FK)───────┼───────┐           ││
               │      │ AppointmentID (FK)───┼───┐   │           ││
               │      │ DepartmentID (FK)───■    │   │           ││
               │      │ Amount                   │   │           ││
               │      │ PaymentStatus            │   │           ││
               │      │ PaymentDate              │   │           ││
               │      │ InsuranceCoverage        │   │           ││
               │      │ CreatedAt                │   │           ││
               │      │ UpdatedAt                │   │           ││
               │      └──────────────────────────┘   │           ││
               │                                     │           ││
               │      ┌──────────────────────┐       │           ││
               └──────┼───  INVENTORY        │      │           ││
                      ├──────────────────────┤      │           ││
                      │ InventoryID (PK)     │      │           ││
                      │ DepartmentID (FK)────┼──┐   │           ││
                      │ MedicationID (FK)────┼──┼───┼──┐         ││
                      │ Quantity             │  │   │  │         ││
                      │ MinimumLevel         │  │   │  │         ││
                      │ ExpiryDate           │  │   │  │         ││
                      │ StorageLocation      │  │   │  │         ││
                      │ CreatedAt            │  │   │  │         ││
                      │ UpdatedAt            │  │   │  │         ││
                      └──────────────────────┘  │   │  │         ││
                                                │   │  │         ││
                                                └───┘  │         ││
                                                       └─────────┘│
                                                                  │
```

## Cardinality Notation Legend

- **1:1** (One-to-One) - Each record in table A relates to exactly one record in table B
- **1:N** (One-to-Many) - Each record in table A can relate to many records in table B
- **N:M** (Many-to-Many) - Records in table A can relate to many records in table B and vice versa
- **FK** (Foreign Key) - Column that references a primary key in another table
- **PK** (Primary Key) - Unique identifier for each record in a table

## Detailed Relationship Summary

### 1. DEPARTMENTS Relationships (Hub Table)
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| DepartmentID → DOCTORS | DOCTORS | 1:N | One department has many doctors |
| DepartmentID → STAFF | STAFF | 1:N | One department has many staff members |
| DepartmentID → INVENTORY | INVENTORY | 1:N | One department manages many inventory items |
| DepartmentID → BILLING | BILLING | 1:N | One department handles many billing records |

### 2. PERSONS - Doctor & Patient Central Relationships

#### DOCTORS Relationships
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| DoctorID → APPOINTMENTS | APPOINTMENTS | 1:N | One doctor conducts many appointments |
| DoctorID → MEDICAL_RECORDS | MEDICAL_RECORDS | 1:N | One doctor creates many medical records |
| DoctorID → LAB_RESULTS | LAB_RESULTS | 1:N | One doctor orders/reviews many lab results |
| DoctorID → PRESCRIPTIONS | PRESCRIPTIONS | 1:N | One doctor prescribes many medications |

#### PATIENTS Relationships
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| PatientID → APPOINTMENTS | APPOINTMENTS | 1:N | One patient attends many appointments |
| PatientID → MEDICAL_RECORDS | MEDICAL_RECORDS | 1:N | One patient has many medical records |
| PatientID → LAB_RESULTS | LAB_RESULTS | 1:N | One patient undergoes many lab tests |
| PatientID → BILLING | BILLING | 1:N | One patient has many billing entries |
| PatientID → PRESCRIPTIONS | PRESCRIPTIONS | 1:N | One patient receives many prescriptions |

### 3. APPOINTMENTS - Event Trigger Relationships
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| AppointmentID → MEDICAL_RECORDS | MEDICAL_RECORDS | 1:N | One appointment generates medical records |
| AppointmentID → BILLING | BILLING | 1:1 | One appointment creates one billing record |

### 4. MEDICATIONS & INVENTORY - Supply Chain Relationships
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| MedicationID → PRESCRIPTIONS | PRESCRIPTIONS | 1:N | One medication is prescribed many times |
| MedicationID → INVENTORY | INVENTORY | 1:N | One medication has many inventory entries |

### 5. LAB TESTS & RESULTS - Testing Relationships
| Foreign Key Reference | Target Table | Cardinality | Description |
|----------------------|--------------|------------|-------------|
| LabTestID → LAB_RESULTS | LAB_RESULTS | 1:N | One test type has many results |

## Complete Relationship Matrix

| From Table | To Table | Relationship | Type | Cardinality |
|-----------|----------|--------------|------|-------------|
| DEPARTMENTS | DOCTORS | DepartmentID (FK) | 1:N | Many doctors per department |
| DOCTORS | APPOINTMENTS | DoctorID (FK) | 1:N | Many appointments per doctor |
| DOCTORS | MEDICAL_RECORDS | DoctorID (FK) | 1:N | Many records per doctor |
| DOCTORS | LAB_RESULTS | DoctorID (FK) | 1:N | Many results per doctor |
| DOCTORS | PRESCRIPTIONS | DoctorID (FK) | 1:N | Many prescriptions per doctor |
| PATIENTS | APPOINTMENTS | PatientID (FK) | 1:N | Many appointments per patient |
| PATIENTS | MEDICAL_RECORDS | PatientID (FK) | 1:N | Many records per patient |
| PATIENTS | LAB_RESULTS | PatientID (FK) | 1:N | Many results per patient |
| PATIENTS | BILLING | PatientID (FK) | 1:N | Many bills per patient |
| PATIENTS | PRESCRIPTIONS | PatientID (FK) | 1:N | Many prescriptions per patient |
| APPOINTMENTS | MEDICAL_RECORDS | AppointmentID (FK) | 1:N | Records created from appointments |
| APPOINTMENTS | BILLING | AppointmentID (FK) | 1:1 | One bill per appointment |
| LAB_TESTS | LAB_RESULTS | LabTestID (FK) | 1:N | Many results per test type |
| MEDICATIONS | PRESCRIPTIONS | MedicationID (FK) | 1:N | Many prescriptions per medication |
| MEDICATIONS | INVENTORY | MedicationID (FK) | 1:N | Inventory tracking per medication |
| DEPARTMENTS | STAFF | DepartmentID (FK) | 1:N | Many staff per department |
| DEPARTMENTS | INVENTORY | DepartmentID (FK) | 1:N | Many items per department |
| DEPARTMENTS | BILLING | DepartmentID (FK) | 1:N | Many charges per department |

## MongoDB Collections and SQL Integration Points

### Normalization Analysis

The database achieves **3rd Normal Form (3NF)** through:

**First Normal Form (1NF):**
- All tables have atomic values (no repeating groups)
- Example: Patient medical conditions stored as text fields, not comma-separated values

**Second Normal Form (2NF):**
- Partial dependencies removed
- Example: Prescription dosage depends on both Medication AND Patient, properly linked via foreign keys

**Third Normal Form (3NF):**
- Transitive dependencies eliminated
- Example: Department budget doesn't appear in Billing (avoids update anomalies)
- All non-key attributes depend only on the primary key

### Table Structure by Business Domain

#### **Personnel Domain**
- **DEPARTMENTS** - Organizational units
- **DOCTORS** - Medical professionals (DepartmentID FK)
- **STAFF** - Administrative/support staff (DepartmentID FK)

#### **Patient Domain**
- **PATIENTS** - Core patient demographic data
- **APPOINTMENTS** - Visit scheduling (PatientID, DoctorID FK)
- **MEDICAL_RECORDS** - Encounter notes (PatientID, DoctorID, AppointmentID FK)

#### **Clinical Domain**
- **LAB_TESTS** - Test type definitions
- **LAB_RESULTS** - Test results (PatientID, LabTestID, DoctorID FK)
- **MEDICATIONS** - Drug catalog
- **PRESCRIPTIONS** - Patient medications (PatientID, MedicationID, DoctorID FK)

#### **Administrative Domain**
- **INVENTORY** - Supply tracking (MedicationID, DepartmentID FK)
- **BILLING** - Financial records (PatientID, AppointmentID, DepartmentID FK)

```
┌──────────────────────────────────────────────────────────┐
│  MONGODB COLLECTIONS (Hybrid SQL-NoSQL Integration)     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  MedicalHistory ─────────────┐                          │
│  {                           │ Referenced Field         │
│    patientId: <PatientID>,───┼──> Patients.PatientID   │
│    doctorId: <DoctorID>      │                          │
│  }                           │                          │
│                              └─> Doctors.DoctorID      │
│                                                          │
│  DiagnosticReports ──────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>,───┼──> Patients.PatientID   │
│    reviewedBy: <DoctorID>    │                          │
│  }                           └─> Doctors.DoctorID      │
│                                                          │
│  ActivityLogs ───────────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>,───┼──> Patients.PatientID   │
│    userId: <DoctorID>        │                          │
│  }                           └─> Doctors.DoctorID      │
│                                                          │
│  Communications ─────────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>,───┼──> Patients.PatientID   │
│    doctorId: <DoctorID>      │                          │
│  }                           └─> Doctors.DoctorID      │
│                                                          │
│  AllergiesRegistry ──────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>,───┼──> Patients.PatientID   │
│    testedBy: <DoctorID>      │                          │
│  }                           └─> Doctors.DoctorID      │
│                                                          │
│  FamilyHistory ──────────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>────┼──> Patients.PatientID   │
│  }                           │                          │
│                              │                          │
│  PatientEducation ───────────┐                          │
│  {                           │                          │
│    patientId: <PatientID>────┼──> Patients.PatientID   │
│  }                           │                          │
│                              │                          │
└──────────────────────────────────────────────────────────┘
```

## Key Features

### SQL Database Features:
- **12 Tables** with ACID compliance and FOREIGN KEY constraints
- **40+ Indexes** for performance optimization
- **5 Stored Procedures** for business logic
- **5 Functions** for calculated fields
- **10 Views** for simplified data access
- **Full-Text Search** on clinical notes and medications
- **Audit Trail** for data integrity
- **Triggers** for automated updates

### NoSQL Database Features:
- **7 Collections** with JSON schema validation
- **Flexible Structure** for unstructured clinical data
- **TTL Indexes** for automatic cleanup of activity logs
- **Compound Indexes** for performance
- **Referential Integrity** linking to SQL tables
- **Nested Objects** for complex medical data

### Data Characteristics:
- **100+ Sample Records** across all tables
- **Realistic Data Distribution** (50 patients, 20 doctors, 25 lab tests)
- **Abnormal and Critical Values** for realistic scenarios
- **Multi-language Support** for patient demographics
- **Insurance Integration** with policy tracking
- **Comprehensive Audit Trail** for compliance

---

**Created: March 2026 | Hospital Management System M605**

---

## Key Constraints and Data Integrity

### Primary Keys (PK)
All tables use surrogate keys (AUTO_INCREMENT integers) for:
- Performance (smaller index size)
- Flexibility (independent of business logic)
- Security (no exposure of sensitive identifiers)

### Foreign Keys (FK)
- **ON DELETE CASCADE** - Removes dependent records (used for non-critical links)
- **ON DELETE RESTRICT** - Prevents deletion if dependents exist (used for critical links)
- All deletions maintain referential integrity

### Unique Constraints
| Table | Field | Purpose |
|-------|-------|---------|
| MEMBERS | member_number | Public member ID |
| MEMBERS | email | Contact identifier |
| DOCTORS | license_number | Medical license |
| DOCTORS | email | Professional contact |
| PATIENTS | ssn/medical_record_id | Patient identifier |
| MEDICATIONS | medication_name | Drug catalog |
| LAB_TESTS | lab_test_name | Test definitions |
| PAYMENTS | receipt_number | Financial audit trail |

### Check Constraints
| Table | Field | Valid Values |
|-------|-------|--------------|
| PATIENTS | gender | Male, Female, Other |
| APPOINTMENTS | status | Scheduled, Confirmed, Completed, Cancelled |
| DOCTORS | availability | Available, On-Leave, Unavailable |
| BILLING | payment_status | Pending, Completed, Failed, Refunded |
| LAB_RESULTS | result_status | Normal, Abnormal, Critical |
| PRESCRIPTIONS | status | Active, Completed, Cancelled |

### Timestamp Tracking
- **created_at** - Record insertion timestamp
- **updated_at** - Last modification timestamp
- **last_modified** - Alternative tracking field
- Automatically managed via TRIGGERS

### Indexes (40+)
- Single-column indexes on all FK fields
- Composite indexes on frequently joined columns
- Full-text search indexes on clinical notes
- Date-range indexes for appointment lookups

---
