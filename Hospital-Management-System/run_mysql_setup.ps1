# Hospital Management System - MySQL Setup Script (PowerShell)
# This script sets up the MySQL database automatically

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hospital Management System MySQL Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if MySQL is running
Write-Host "Checking MySQL status..." -ForegroundColor Yellow
$mysqlRunning = Get-Service MySQL96 -ErrorAction SilentlyContinue
if ($mysqlRunning.Status -ne "Running") {
    Write-Host "⚠️  MySQL service not running. Starting..." -ForegroundColor Yellow
    Start-Service MySQL96 -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Get password from user
Write-Host ""
Write-Host "Please enter your MySQL root password:" -ForegroundColor Yellow
Write-Host "(If empty, just press ENTER)" -ForegroundColor Gray

# Read password securely
$securePassword = Read-Host -Prompt "MySQL root password" -AsSecureString
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($securePassword))

# Navigate to SQL directory
$sqlPath = "C:\Users\Leore\Desktop\sql data base\Hospital-Management-System\SQL"
Push-Location $sqlPath

Write-Host ""
Write-Host "Creating database and tables..." -ForegroundColor Green

# Prepare connection string
if ($plainPassword) {
    $connString = "mysql -u root -p$plainPassword"
} else {
    $connString = "mysql -u root"
}

# Run schema creation
Write-Host ""
Write-Host "📋 Executing: 01_schema_creation.sql" -ForegroundColor Cyan
Get-Content "01_schema_creation.sql" | & "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root $(if ($plainPassword) { "-p$plainPassword" })

Write-Host ""
Write-Host "Loading sample data..." -ForegroundColor Green
Write-Host ""
Write-Host "📋 Executing: 02_sample_data.sql" -ForegroundColor Cyan
Get-Content "02_sample_data.sql" | & "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root $(if ($plainPassword) { "-p$plainPassword" })

Pop-Location

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your MySQL Hospital Management Database is ready!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open MySQL Workbench" -ForegroundColor White
Write-Host "2. Connect to Local instance MySQL" -ForegroundColor White
Write-Host "3. Browse HospitalManagement database" -ForegroundColor White
Write-Host "4. View your 100+ records in each table" -ForegroundColor White
Write-Host ""
Write-Host "Or run more SQL scripts:" -ForegroundColor Cyan
Write-Host "  • 03_advanced_analytics_queries.sql" -ForegroundColor White
Write-Host "  • 04_views_and_materialized_queries.sql" -ForegroundColor White
Write-Host "  • 05_stored_procedures_and_functions.sql" -ForegroundColor White
Write-Host ""
