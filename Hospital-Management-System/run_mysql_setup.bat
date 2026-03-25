@echo off
REM Hospital Management System - MySQL Setup Script
REM This script sets up the MySQL database with schema and sample data

echo.
echo ========================================
echo Hospital Management System MySQL Setup
echo ========================================
echo.

REM Change to SQL directory
cd /d "C:\Users\Leore\Desktop\sql data base\Hospital-Management-System\SQL"

REM Display instructions
echo.
echo IMPORTANT: You need your MySQL root password
echo.
echo Please enter your MySQL root password when prompted:
echo (If you have never set a password, just press ENTER)
echo.

REM Execute schema creation
echo Creating database and schema...
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -p < 01_schema_creation.sql

echo.
echo Loading sample data...
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -p < 02_sample_data.sql

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Your MySQL Hospital Management Database is ready!
echo.
echo Next steps:
echo 1. Open MySQL Workbench
echo 2. Browse the HospitalManagement database
echo 3. View your 100+ records in each table
echo.
pause
