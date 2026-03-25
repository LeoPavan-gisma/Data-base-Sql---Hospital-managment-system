// Hospital Management System - MongoDB Schema and Collections
// M605 Advanced Databases - NoSQL Implementation
// File: NoSQL Schema and Data Structure

// ============================================================================
// MONGODB COLLECTIONS STRUCTURE
// ============================================================================

// Collection 1: Medical History and Clinical Notes
db.createCollection("MedicalHistory", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "recordDate", "content"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int", description: "Patient ID from SQL" },
                doctorId: { bsonType: "int", description: "Doctor ID from SQL" },
                recordDate: { bsonType: "date", description: "Date of record" },
                recordType: { 
                    enum: ["Progress Note", "Discharge Summary", "Consultation Note", "Follow-up Note"],
                    description: "Type of medical record"
                },
                content: { bsonType: "string", description: "Clinical notes and observations" },
                diagnosis: { bsonType: "array", items: { bsonType: "string" } },
                vitals: {
                    bsonType: "object",
                    properties: {
                        temperature: { bsonType: "double", description: "Body temperature in Celsius" },
                        heartRate: { bsonType: "int", description: "Beats per minute" },
                        bloodPressure: { bsonType: "string", description: "Systolic/Diastolic" },
                        respiratoryRate: { bsonType: "int" },
                        oxygenSaturation: { bsonType: "double" }
                    }
                },
                medications: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            medicationName: { bsonType: "string" },
                            dosage: { bsonType: "string" },
                            frequency: { bsonType: "string" }
                        }
                    }
                },
                assessments: { bsonType: "string", description: "Clinical assessment" },
                plan: { bsonType: "string", description: "Treatment plan" },
                attachments: {
                    bsonType: "array",
                    items: { bsonType: "string", description: "File paths or URLs" }
                },
                createdAt: { bsonType: "date" },
                updatedAt: { bsonType: "date" }
            }
        }
    }
});

// Collection 2: Patient Imaging and Diagnostic Reports
db.createCollection("DiagnosticReports", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "reportDate", "reportType"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                doctorId: { bsonType: "int" },
                reportDate: { bsonType: "date" },
                reportType: {
                    enum: ["X-Ray", "CT Scan", "MRI", "Ultrasound", "PET Scan", "ECG", "Echocardiogram"],
                    description: "Type of diagnostic test"
                },
                bodyPart: { bsonType: "string", description: "Area examined" },
                imagingCenter: { bsonType: "string" },
                findings: { bsonType: "string", description: "Detailed findings" },
                impression: { bsonType: "string", description: "Overall impression" },
                recommendations: { bsonType: "string" },
                imageUrls: {
                    bsonType: "array",
                    items: { bsonType: "string" }
                },
                qualityScore: { bsonType: "double", minimum: 0, maximum: 100 },
                reviewed: { bsonType: "bool" },
                reviewedBy: { bsonType: "int", description: "Radiologist doctor ID" },
                reviewDate: { bsonType: "date" },
                createdAt: { bsonType: "date" }
            }
        }
    }
});

// Collection 3: Patient Activity Logs and Audit Trail
db.createCollection("ActivityLogs", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "timestamp", "action"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                userId: { bsonType: "int", description: "Doctor or staff ID" },
                timestamp: { bsonType: "date" },
                action: {
                    enum: ["Appointment Created", "Appointment Completed", "Lab Test Ordered", 
                           "Prescription Issued", "Medical Record Accessed", "Report Generated",
                           "Patient Contacted", "Referral Made"],
                    description: "Type of action"
                },
                description: { bsonType: "string" },
                details: { bsonType: "object", additionalProperties: true },
                status: { enum: ["Success", "Pending", "Failed"] },
                ipAddress: { bsonType: "string" },
                userAgent: { bsonType: "string" }
            }
        }
    }
});

// Collection 4: Patient Communication and Messages
db.createCollection("Communications", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "timestamp", "type"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                doctorId: { bsonType: "int" },
                timestamp: { bsonType: "date" },
                type: { enum: ["SMS", "Email", "In-App Message", "Call", "Appointment Reminder"] },
                subject: { bsonType: "string" },
                body: { bsonType: "string" },
                isRead: { bsonType: "bool" },
                readDate: { bsonType: "date" },
                priority: { enum: ["Low", "Medium", "High", "Urgent"] },
                attachments: { bsonType: "array", items: { bsonType: "string" } },
                responses: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            respondentId: { bsonType: "int" },
                            responseDate: { bsonType: "date" },
                            responseText: { bsonType: "string" }
                        }
                    }
                }
            }
        }
    }
});

// Collection 5: Allergies and Adverse Reactions Registry
db.createCollection("AllergiesRegistry", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "allergen"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                allergen: { bsonType: "string" },
                severity: { enum: ["Mild", "Moderate", "Severe", "Anaphylactic"] },
                reactionType: {
                    enum: ["Drug", "Food", "Environmental", "Latex", "Other"],
                    description: "Category of allergen"
                },
                symptoms: {
                    bsonType: "array",
                    items: { bsonType: "string" }
                },
                onsetDate: { bsonType: "date" },
                reactions: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            incidentDate: { bsonType: "date" },
                            severity: { bsonType: "string" },
                            treatment: { bsonType: "string" },
                            outcome: { bsonType: "string" }
                        }
                    }
                },
                testedBy: { bsonType: "int", description: "Doctor ID" },
                testDate: { bsonType: "date" },
                verified: { bsonType: "bool" },
                notes: { bsonType: "string" }
            }
        }
    }
});

// Collection 6: Patient Family History and Genetics
db.createCollection("FamilyHistory", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                familyMembers: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            relationship: {
                                enum: ["Mother", "Father", "Sibling", "Grandparent", "Aunt", "Uncle", "Cousin"],
                                description: "Relationship to patient"
                            },
                            name: { bsonType: "string" },
                            age: { bsonType: "int" },
                            medicalConditions: { bsonType: "array", items: { bsonType: "string" } },
                            isAlive: { bsonType: "bool" },
                            causeOfDeath: { bsonType: "string" },
                            notes: { bsonType: "string" }
                        }
                    }
                },
                geneticTestResults: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            testName: { bsonType: "string" },
                            testDate: { bsonType: "date" },
                            result: { bsonType: "string" },
                            riskAssessment: { bsonType: "string" }
                        }
                    }
                },
                hereditaryDiseases: { bsonType: "array", items: { bsonType: "string" } },
                lastUpdated: { bsonType: "date" }
            }
        }
    }
});

// Collection 7: Patient Education and Health Information
db.createCollection("PatientEducation", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["patientId", "contentType"],
            properties: {
                _id: { bsonType: "objectId" },
                patientId: { bsonType: "int" },
                contentType: {
                    enum: ["Disease Information", "Medication Instructions", "Lifestyle Advice", 
                           "Preventive Care", "Post-Surgery Instructions", "Lab Test Explanation"],
                    description: "Category of educational content"
                },
                title: { bsonType: "string" },
                content: { bsonType: "string" },
                attachments: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            fileName: { bsonType: "string" },
                            fileType: { bsonType: "string" },
                            fileUrl: { bsonType: "string" }
                        }
                    }
                },
                videos: { bsonType: "array", items: { bsonType: "string", description: "YouTube URLs" } },
                assignedDate: { bsonType: "date" },
                completionDate: { bsonType: "date" },
                isCompleted: { bsonType: "bool" },
                quizScore: { bsonType: "double", minimum: 0, maximum: 100 }
            }
        }
    }
});

// ============================================================================
// CREATE INDEXES FOR PERFORMANCE
// ============================================================================

db.MedicalHistory.createIndex({ "patientId": 1, "recordDate": -1 });
db.MedicalHistory.createIndex({ "doctorId": 1 });
db.MedicalHistory.createIndex({ "recordType": 1 });

db.DiagnosticReports.createIndex({ "patientId": 1, "reportDate": -1 });
db.DiagnosticReports.createIndex({ "reportType": 1 });
db.DiagnosticReports.createIndex({ "reviewed": 1, "reviewDate": 1 });

db.ActivityLogs.createIndex({ "patientId": 1, "timestamp": -1 });
db.ActivityLogs.createIndex({ "userId": 1 });
db.ActivityLogs.createIndex({ "action": 1 });
db.ActivityLogs.createIndex({ "timestamp": -1 }, { expireAfterSeconds: 7776000 }); // 90 days

db.Communications.createIndex({ "patientId": 1, "timestamp": -1 });
db.Communications.createIndex({ "doctorId": 1 });
db.Communications.createIndex({ "isRead": 1, "type": 1 });

db.AllergiesRegistry.createIndex({ "patientId": 1 });
db.AllergiesRegistry.createIndex({ "allergen": 1 });
db.AllergiesRegistry.createIndex({ "severity": 1 });

db.FamilyHistory.createIndex({ "patientId": 1 });

db.PatientEducation.createIndex({ "patientId": 1, "contentType": 1 });
db.PatientEducation.createIndex({ "isCompleted": 1 });
