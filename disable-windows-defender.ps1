<#
    Windows Defender Disabler - Working Version
    
    This PowerShell script disables Windows Defender using multiple methods.
    For educational/research use only in isolated lab environments.
    
    Usage: Run as Administrator
#>

# Require Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges." -ForegroundColor Red
    exit 1
}

# Configuration
$serviceName = "WinDefend"
$backupFile = "$env:TEMP\DefenderBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

# Main execution with error handling
try {
    Write-Host "Windows Defender Disabler - Starting..." -ForegroundColor Cyan
    
    # Backup registry
    try {
        Write-Host "Backing up current Defender settings..."
        reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" $backupFile /y
        Write-Host "✓ Backup created: $backupFile" -ForegroundColor Green
    } catch {
        Write-Host "✗ Backup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Method 1: Disable service
    try {
        Write-Host "Stopping Windows Defender service..."
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
        Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
        Write-Host "✓ Service disabled" -ForegroundColor Green
    } catch {
        Write-Host "✗ Service disable failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Method 2: Disable real-time protection
    try {
        Write-Host "Disabling real-time protection..."
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction Stop
        Set-MpPreference -DisableScriptScanning $true -ErrorAction Stop
        Write-Host "✓ Real-time protection disabled" -ForegroundColor Green
    } catch {
        Write-Host "✗ Real-time protection disable failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Method 3: Registry settings
    try {
        Write-Host "Setting registry disable flags..."
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "$regPath\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Force -ErrorAction Stop
        Write-Host "✓ Registry settings applied" -ForegroundColor Green
    } catch {
        Write-Host "✗ Registry method failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Method 4: Terminate processes
    try {
        Write-Host "Terminating Defender processes..."
        $processes = @("MsMpEng", "NisSrv", "MpCmdRun")
        foreach ($process in $processes) {
            Get-Process -Name $process -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Write-Host "✓ Processes terminated" -ForegroundColor Green
    } catch {
        Write-Host "✗ Process termination failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "`nDefender disable process completed." -ForegroundColor Green
    Write-Host "Note: Some changes may require a system reboot." -ForegroundColor Yellow
    Write-Host "Backup file: $backupFile" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n❌ Script failed with error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Attempting to restore from backup if available..." -ForegroundColor Yellow
    if (Test-Path $backupFile) {
        try {
            reg import $backupFile
            Write-Host "✓ Restored from backup" -ForegroundColor Green
        } catch {
            Write-Host "✗ Restore failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}