

use HospitalManagement;


db.MedicalHistory.insertMany([
    {
        patientId: 1,
        doctorId: 1,
        recordDate: new Date("2026-03-15"),
        recordType: "Progress Note",
        content: "Patient presents with chest pain and shortness of breath. BP elevated at 160/95. EKG ordered. Patient instructed to monitor symptoms.",
        diagnosis: ["Hypertension", "Chest Pain"],
        vitals: {
            temperature: 37.2,
            heartRate: 88,
            bloodPressure: "160/95",
            respiratoryRate: 18,
            oxygenSaturation: 97.5
        },
        medications: [
            { medicationName: "Lisinopril", dosage: "10mg", frequency: "Once daily" },
            { medicationName: "Atorvastatin", dosage: "20mg", frequency: "Once daily" }
        ],
        assessments: "Cardiovascular assessment required. Patient at moderate risk.",
        plan: "Monitor BP, continue medications, follow-up in 2 weeks",
        attachments: ["EKG_2026-03-15.pdf"],
        createdAt: new Date("2026-03-15T09:00:00Z"),
        updatedAt: new Date("2026-03-15T09:00:00Z")
    },
    {
        patientId: 2,
        doctorId: 3,
        recordDate: new Date("2026-03-14"),
        recordType: "Consultation Note",
        content: "Patient reports persistent joint pain in knees bilaterally. Physical examination shows swelling and limited range of motion. X-rays ordered to rule out osteoarthritis.",
        diagnosis: ["Knee Pain", "Possible Osteoarthritis"],
        vitals: {
            temperature: 36.8,
            heartRate: 72,
            bloodPressure: "140/85",
            respiratoryRate: 16,
            oxygenSaturation: 98.0
        },
        medications: [
            { medicationName: "Ibuprofen", dosage: "400mg", frequency: "Three times daily" }
        ],
        assessments: "Mild degenerative changes suspected. Physical therapy recommended.",
        plan: "X-ray imaging, NSAIDs, physical therapy referral",
        attachments: ["XRay_Knees_2026-03-14.pdf"],
        createdAt: new Date("2026-03-14T10:30:00Z"),
        updatedAt: new Date("2026-03-14T10:30:00Z")
    },
    {
        patientId: 3,
        doctorId: 4,
        recordDate: new Date("2026-03-13"),
        recordType: "Follow-up Note",
        content: "Patient recovering well from surgery. Wound healing appropriately. Pain controlled with current medication regimen. Encouraged to increase activity gradually.",
        diagnosis: ["Post-operative Recovery"],
        vitals: {
            temperature: 37.0,
            heartRate: 75,
            bloodPressure: "138/82",
            respiratoryRate: 17,
            oxygenSaturation: 98.5
        },
        medications: [
            { medicationName: "Tramadol", dosage: "50mg", frequency: "Every 6 hours as needed" },
            { medicationName: "Amoxicillin", dosage: "500mg", frequency: "Three times daily" }
        ],
        assessments: "Excellent post-operative progress. No complications noted.",
        plan: "Continue antibiotics, pain management, follow-up visit in 1 week",
        attachments: [],
        createdAt: new Date("2026-03-13T11:00:00Z"),
        updatedAt: new Date("2026-03-13T11:00:00Z")
    },
    {
        patientId: 4,
        doctorId: 2,
        recordDate: new Date("2026-03-12"),
        recordType: "Progress Note",
        content: "Regular cardiac checkup. Patient reports good compliance with medications. No new symptoms reported. Echocardiogram scheduled for next month.",
        diagnosis: ["Hypertension", "Heart Disease"],
        vitals: {
            temperature: 36.9,
            heartRate: 70,
            bloodPressure: "145/88",
            respiratoryRate: 16,
            oxygenSaturation: 99.0
        },
        medications: [
            { medicationName: "Metoprolol", dosage: "50mg", frequency: "Twice daily" },
            { medicationName: "Ramipril", dosage: "5mg", frequency: "Once daily" }
        ],
        assessments: "Stable cardiac condition. Continue current regimen.",
        plan: "Echocardiogram, continue medications, follow-up in 4 weeks",
        attachments: [],
        createdAt: new Date("2026-03-12T09:30:00Z"),
        updatedAt: new Date("2026-03-12T09:30:00Z")
    },
    {
        patientId: 5,
        doctorId: 5,
        recordDate: new Date("2026-03-11"),
        recordType: "Progress Note",
        content: "Patient reports elevated anxiety symptoms. Nighttime panic attacks affecting sleep quality. Referred to psychiatry. Prescribed SSRI for symptom management.",
        diagnosis: ["Anxiety Disorder", "Panic Disorder"],
        vitals: {
            temperature: 37.1,
            heartRate: 95,
            bloodPressure: "155/92",
            respiratoryRate: 20,
            oxygenSaturation: 98.0
        },
        medications: [
            { medicationName: "Sertraline", dosage: "50mg", frequency: "Once daily" },
            { medicationName: "Alprazolam", dosage: "0.5mg", frequency: "As needed for anxiety" }
        ],
        assessments: "Moderate anxiety disorder. Requires psychiatric care.",
        plan: "SSRI therapy, psychiatric referral, cognitive behavioral therapy",
        attachments: ["Psychiatry_Referral_2026-03-11.pdf"],
        createdAt: new Date("2026-03-11T14:00:00Z"),
        updatedAt: new Date("2026-03-11T14:00:00Z")
    }
]);

// Insert more medical history records (bulk insertion for demo)
const medicalHistoryBulk = [];
for (let i = 6; i <= 25; i++) {
    medicalHistoryBulk.push({
        patientId: (i % 50) + 1,
        doctorId: (i % 20) + 1,
        recordDate: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000),
        recordType: ["Progress Note", "Consultation Note", "Follow-up Note", "Discharge Summary"][Math.floor(Math.random() * 4)],
        content: `Clinical note for patient ${(i % 50) + 1}. Standard examination performed. Patient appears stable.`,
        diagnosis: ["Hypertension", "Diabetes", "Asthma", "Arthritis"][Math.floor(Math.random() * 4)],
        vitals: {
            temperature: 36.5 + Math.random() * 1.5,
            heartRate: 60 + Math.floor(Math.random() * 40),
            bloodPressure: (120 + Math.floor(Math.random() * 40)) + "/" + (80 + Math.floor(Math.random() * 25)),
            respiratoryRate: 12 + Math.floor(Math.random() * 10),
            oxygenSaturation: 95 + Math.random() * 4
        },
        medications: [
            { medicationName: "Medication " + i, dosage: "10mg", frequency: "Once daily" }
        ],
        assessments: "Patient stable. Continue current treatment plan.",
        plan: "Follow-up as needed",
        attachments: [],
        createdAt: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000),
        updatedAt: new Date()
    });
}
db.MedicalHistory.insertMany(medicalHistoryBulk);

// ============================================================================
// Collection 2: DiagnosticReports - Imaging and Test Results (40+ documents)
// ============================================================================

db.DiagnosticReports.insertMany([
    {
        patientId: 1,
        doctorId: 1,
        reportDate: new Date("2026-03-15"),
        reportType: "ECG",
        bodyPart: "Heart",
        imagingCenter: "Cardiology Department",
        findings: "Normal sinus rhythm. No acute ST-T wave changes. QTc interval normal.",
        impression: "Normal electrocardiogram. No acute cardiac abnormality.",
        recommendations: "Clinical correlation recommended. Continue current medications.",
        imageUrls: ["ecg_patient1_2026-03-15.png"],
        qualityScore: 95.0,
        reviewed: true,
        reviewedBy: 1,
        reviewDate: new Date("2026-03-15T10:00:00Z"),
        createdAt: new Date("2026-03-15T09:15:00Z")
    },
    {
        patientId: 2,
        doctorId: 3,
        reportDate: new Date("2026-03-14"),
        reportType: "X-Ray",
        bodyPart: "Knees",
        imagingCenter: "Radiology Department",
        findings: "Mild joint space narrowing noted in both knees. Early degenerative changes visible.",
        impression: "Mild osteoarthritis of bilateral knees.",
        recommendations: "Physical therapy. NSAIDs for pain management. Follow-up imaging in 1 year.",
        imageUrls: ["xray_knee_left_2026-03-14.png", "xray_knee_right_2026-03-14.png"],
        qualityScore: 88.5,
        reviewed: true,
        reviewedBy: 8,
        reviewDate: new Date("2026-03-14T11:30:00Z"),
        createdAt: new Date("2026-03-14T10:45:00Z")
    },
    {
        patientId: 5,
        doctorId: 5,
        reportDate: new Date("2026-03-10"),
        reportType: "CT Scan",
        bodyPart: "Brain",
        imagingCenter: "Neurology Department",
        findings: "No acute intracranial abnormality. No mass effect. No midline shift. Ventricles normal in size and configuration.",
        impression: "Normal CT brain. No acute findings.",
        recommendations: "Clinical correlation required. No acute intervention needed.",
        imageUrls: ["ct_brain_patient5_2026-03-10_axial.png", "ct_brain_patient5_2026-03-10_coronal.png"],
        qualityScore: 92.0,
        reviewed: true,
        reviewedBy: 4,
        reviewDate: new Date("2026-03-10T13:00:00Z"),
        createdAt: new Date("2026-03-10T12:15:00Z")
    }
]);

// Bulk insert diagnostic reports
const diagnosticBulk = [];
const reportTypes = ["X-Ray", "CT Scan", "MRI", "Ultrasound", "ECG"];
for (let i = 4; i <= 25; i++) {
    diagnosticBulk.push({
        patientId: (i % 50) + 1,
        doctorId: (i % 20) + 1,
        reportDate: new Date(Date.now() - Math.random() * 60 * 24 * 60 * 60 * 1000),
        reportType: reportTypes[Math.floor(Math.random() * reportTypes.length)],
        bodyPart: ["Chest", "Abdomen", "Head", "Spine", "Extremities"][Math.floor(Math.random() * 5)],
        imagingCenter: "Radiology Department",
        findings: "Standard findings noted. No acute abnormality detected.",
        impression: "Routine imaging without significant findings.",
        recommendations: "Follow-up as clinically indicated.",
        imageUrls: ["image_" + i + ".png"],
        qualityScore: 85 + Math.random() * 15,
        reviewed: true,
        reviewedBy: (i % 20) + 1,
        reviewDate: new Date(Date.now() - Math.random() * 50 * 24 * 60 * 60 * 1000),
        createdAt: new Date(Date.now() - Math.random() * 60 * 24 * 60 * 60 * 1000)
    });
}
db.DiagnosticReports.insertMany(diagnosticBulk);

// ============================================================================
// Collection 3: ActivityLogs - Audit Trail (100+ documents)
// ============================================================================

const activityActions = ["Appointment Created", "Appointment Completed", "Lab Test Ordered", 
                        "Prescription Issued", "Medical Record Accessed", "Report Generated"];

const activityBulk = [];
for (let i = 1; i <= 100; i++) {
    activityBulk.push({
        patientId: (i % 50) + 1,
        userId: (i % 20) + 1,
        timestamp: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000),
        action: activityActions[Math.floor(Math.random() * activityActions.length)],
        description: "Activity log entry " + i,
        details: {
            entityType: "Appointment",
            entityId: 1000 + i,
            changeType: "Create"
        },
        status: ["Success", "Pending", "Failed"][Math.floor(Math.random() * 3)],
        ipAddress: "192.168." + Math.floor(Math.random() * 255) + "." + Math.floor(Math.random() * 255),
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    });
}
db.ActivityLogs.insertMany(activityBulk);

// ============================================================================
// Collection 4: Communications - Patient Messages (50+ documents)
// ============================================================================

const communicationBulk = [];
const msgTypes = ["SMS", "Email", "In-App Message", "Call", "Appointment Reminder"];
const priorities = ["Low", "Medium", "High", "Urgent"];

for (let i = 1; i <= 50; i++) {
    communicationBulk.push({
        patientId: (i % 50) + 1,
        doctorId: (i % 20) + 1,
        timestamp: new Date(Date.now() - Math.random() * 15 * 24 * 60 * 60 * 1000),
        type: msgTypes[Math.floor(Math.random() * msgTypes.length)],
        subject: "Subject for message " + i,
        body: "Message body content for communication " + i,
        isRead: Math.random() > 0.4,
        readDate: Math.random() > 0.4 ? new Date(Date.now() - Math.random() * 10 * 24 * 60 * 60 * 1000) : null,
        priority: priorities[Math.floor(Math.random() * priorities.length)],
        attachments: [],
        responses: []
    });
}
db.Communications.insertMany(communicationBulk);

// ============================================================================
// Collection 5: AllergiesRegistry - Allergy Records (40+ documents)
// ============================================================================

const allergyBulk = [];
const allergens = ["Penicillin", "Aspirin", "Latex", "Shellfish", "Peanuts", "Iodine", "Codeine", "NSAIDs"];
const severities = ["Mild", "Moderate", "Severe", "Anaphylactic"];
const allergySymptoms = {
    "Penicillin": ["Rash", "Anaphylaxis", "Swelling"],
    "Aspirin": ["Hives", "Wheezing", "Difficulty breathing"],
    "Latex": ["Itching", "Rash", "Swelling"],
    "Shellfish": ["Swelling", "Difficulty breathing", "Anaphylaxis"],
    "Peanuts": ["Swelling", "Anaphylaxis", "Throat tightness"],
    "Iodine": ["Rash", "Swelling", "Difficulty breathing"],
    "Codeine": ["Hives", "Rash", "Difficulty breathing"],
    "NSAIDs": ["Stomach pain", "Hives", "Rash"]
};

for (let i = 1; i <= 40; i++) {
    const selectedAllergen = allergens[Math.floor(Math.random() * allergens.length)];
    allergyBulk.push({
        patientId: (i % 50) + 1,
        allergen: selectedAllergen,
        severity: severities[Math.floor(Math.random() * severities.length)],
        reactionType: ["Drug", "Food", "Environmental", "Latex", "Other"][Math.floor(Math.random() * 5)],
        symptoms: allergySymptoms[selectedAllergen],
        onsetDate: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        reactions: [
            {
                incidentDate: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
                severity: severities[Math.floor(Math.random() * severities.length)],
                treatment: (i % 3 === 0) ? "Epinephrine" : (i % 3 === 1) ? "Antihistamine" : "Corticosteroid",
                outcome: ["Resolved", "Managed", "Hospitalized"][Math.floor(Math.random() * 3)]
            }
        ],
        testedBy: (i % 20) + 1,
        testDate: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        verified: true,
        notes: "Allergy record for patient " + ((i % 50) + 1)
    });
}
db.AllergiesRegistry.insertMany(allergyBulk);

// ============================================================================
// Collection 6: FamilyHistory - Genetic and Family Records (30+ documents)
// ============================================================================

const familyBulk = [];
const familyDiseases = ["Hypertension", "Diabetes", "Heart Disease", "Cancer", "Stroke", "Asthma", "Arthritis", "Kidney Disease"];
const femaleNames = ["Mary", "Patricia", "Jennifer", "Linda", "Barbara"];
const maleNames = ["James", "Robert", "Michael", "William", "David"];

for (let i = 1; i <= 30; i++) {
    const mothersConditions = [familyDiseases[Math.floor(Math.random() * familyDiseases.length)], familyDiseases[Math.floor(Math.random() * familyDiseases.length)]];
    const fathersConditions = [familyDiseases[Math.floor(Math.random() * familyDiseases.length)]];
    
    familyBulk.push({
        patientId: (i % 50) + 1,
        familyMembers: [
            {
                relationship: "Mother",
                name: femaleNames[Math.floor(Math.random() * femaleNames.length)],
                age: 60 + Math.floor(Math.random() * 30),
                medicalConditions: mothersConditions,
                isAlive: Math.random() > 0.2,
                notes: "Manages conditions with regular checkups"
            },
            {
                relationship: "Father",
                name: maleNames[Math.floor(Math.random() * maleNames.length)],
                age: 65 + Math.floor(Math.random() * 30),
                medicalConditions: fathersConditions,
                isAlive: Math.random() > 0.25,
                notes: "Health status tracked quarterly"
            }
        ],
        geneticTestResults: [
            {
                testName: "BRCA1/BRCA2 Genetic Test",
                testDate: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
                result: "Negative",
                riskAssessment: "Low Risk"
            }
        ],
        hereditaryDiseases: ["Heart Disease", "Diabetes"],
        lastUpdated: new Date()
    });
}
db.FamilyHistory.insertMany(familyBulk);

// ============================================================================
// Collection 7: PatientEducation - Health Education Content (35+ documents)
// ============================================================================

const educationBulk = [];
const contentTypes = ["Disease Information", "Medication Instructions", "Lifestyle Advice", 
                      "Preventive Care", "Post-Surgery Instructions", "Lab Test Explanation"];

for (let i = 1; i <= 35; i++) {
    educationBulk.push({
        patientId: (i % 50) + 1,
        contentType: contentTypes[Math.floor(Math.random() * contentTypes.length)],
        title: "Educational Material on " + contentTypes[Math.floor(Math.random() * contentTypes.length)],
        content: "Detailed patient education covering pathophysiology, management strategies, prevention tips, and lifestyle modifications for optimal health outcomes.",
        attachments: [
            {
                fileName: "health_guide_" + i + ".pdf",
                fileType: "PDF",
                fileUrl: "/education/materials/health_guide_" + i + ".pdf",
                fileSize: Math.floor(Math.random() * 5) + 1 + " MB"
            }
        ],
        videos: Math.random() > 0.5 ? ["https://www.youtube.com/watch?v=health_" + i] : [],
        tags: ["health", "patient-education", "training"],
        assignedDate: new Date(Date.now() - Math.random() * 60 * 24 * 60 * 60 * 1000),
        completionDate: Math.random() > 0.4 ? new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000) : null,
        isCompleted: Math.random() > 0.4,
        quizScore: Math.random() > 0.4 ? 65 + Math.floor(Math.random() * 35) : null
    });
}
db.PatientEducation.insertMany(educationBulk);

console.log("MongoDB data insertion complete!");
console.log("Summary: 25+ Medical History records");
console.log("Summary: 25+ Diagnostic Reports");
console.log("Summary: 100+ Activity Logs");
console.log("Summary: 50+ Communications");
console.log("Summary: 40+ Allergies Registry records");
console.log("Summary: 30+ Family History records");
console.log("Summary: 35+ Patient Education records");
console.log("Total: 300+ documents across 7 collections");
