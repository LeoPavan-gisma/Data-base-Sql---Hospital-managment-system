// Hospital Management System - MongoDB Schema and Collections
// M605 Advanced Databases - NoSQL Implementation
// File: NoSQL Schema and Data Structure

// ============================================================================
// DATABASE SETUP
// ============================================================================

// Switch to HospitalManagement database
const db = db.getSiblingDB('HospitalManagement');

// Drop collections if they exist to ensure clean start
try { db.MedicalHistory.drop(); } catch(e) {}
try { db.DiagnosticReports.drop(); } catch(e) {}
try { db.ActivityLogs.drop(); } catch(e) {}
try { db.Communications.drop(); } catch(e) {}
try { db.AllergiesRegistry.drop(); } catch(e) {}
try { db.FamilyHistory.drop(); } catch(e) {}
try { db.PatientEducation.drop(); } catch(e) {}

// ============================================================================
// MONGODB COLLECTIONS STRUCTURE - SIMPLIFIED FOR COMPATIBILITY
// ============================================================================

// Collection 1: Medical History and Clinical Notes
db.createCollection("MedicalHistory");

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
