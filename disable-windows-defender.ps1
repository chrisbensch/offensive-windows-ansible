<#
    Windows Defender Disabler - Comprehensive Script
    
    This PowerShell script provides multiple methods to disable Windows Defender
    for offensive security testing in isolated lab environments.
    
    WARNING: This script is for EDUCATIONAL and RESEARCH purposes only.
    Only use in isolated lab environments on systems you own or have permission to test.
    Disabling Windows Defender reduces system security and should not be done on production systems.
    
    Usage:
    1. Save this script as `disable-windows-defender.ps1`
    2. Run as Administrator: .\disable-windows-defender.ps1
    3. Follow the prompts
#>

<#
    CHANGELOG:
    - Added multiple disabling methods for comprehensive coverage
    - Added registry backup and restore functionality
    - Added service and process termination
    - Added scheduled task removal
    - Added group policy configuration
    - Added comprehensive error handling
    - Added verification functions
#>

# Require Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[!] This script requires Administrator privileges.`n" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Script configuration
$ScriptConfig = @{
    DefenderServiceName = "WinDefend"
    DefenderProcessNames = @("MsMpEng", "NisSrv", "MpCmdRun")
    DefenderScheduledTasks = @("Windows Defender Cache Maintenance", "Windows Defender Cleanup", "Windows Defender Scheduled Scan", "Windows Defender Verification")
    DefenderRegistryPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
    )
    DefenderGPOPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
    )
    BackupFile = "$env:TEMP\DefenderBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
}

# Display script header
Write-Host "`n==========================================" -ForegroundColor Red
Write-Host "  Windows Defender Disabler Script" -ForegroundColor Red
Write-Host "  FOR LAB ENVIRONMENTS ONLY" -ForegroundColor Red
Write-Host "==========================================`n" -ForegroundColor Red

# Function to display section header
function Show-SectionHeader {
    param([string]$title)
    Write-Host "`n[$title]" -ForegroundColor Yellow
    Write-Host "$( '-' * 50)" -ForegroundColor DarkGray
}

# Function to backup registry settings
function Backup-DefenderRegistry {
    try {
        # Export current Windows Defender registry settings
        reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" $ScriptConfig.BackupFile /y
        Write-Host "  ✓ Registry backup created: $($ScriptConfig.BackupFile)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ✗ Registry backup failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to restore registry settings
function Restore-DefenderRegistry {
    param([string]$backupFile)
    
    if (Test-Path $backupFile) {
        try {
            reg import $backupFile
            Write-Host "  ✓ Registry restored from backup" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "  ✗ Registry restore failed: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "  ✗ Backup file not found: $backupFile" -ForegroundColor Red
        return $false
    }
}

# Function to verify Windows Defender status
function Test-DefenderStatus {
    try {
        $defenderStatus = Get-MpComputerStatus
        $realTimeProtection = Get-MpPreference
        
        $statusInfo = @{
            IsEnabled = $defenderStatus.AMServiceEnabled
            RealTimeProtection = $realTimeProtection.DisableRealtimeMonitoring
            BehaviorMonitoring = $realTimeProtection.DisableBehaviorMonitoring
            ScriptScanning = $realTimeProtection.DisableScriptScanning
            IOAVProtection = $realTimeProtection.DisableIOAVProtection
            ServiceRunning = (Get-Service -Name $ScriptConfig.DefenderServiceName -ErrorAction SilentlyContinue).Status -eq "Running"
        }
        
        return $statusInfo
    } catch {
        Write-Host "  ✗ Could not determine Defender status: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to display current status
function Show-DefenderStatus {
    $status = Test-DefenderStatus
    
    if ($status -ne $null) {
        Write-Host "  Current Windows Defender Status:" -ForegroundColor Cyan
        Write-Host "    Service Enabled: $($status.IsEnabled)" -ForegroundColor Cyan
        Write-Host "    Service Running: $($status.ServiceRunning)" -ForegroundColor Cyan
        Write-Host "    Real-Time Protection: $($status.RealTimeProtection)" -ForegroundColor Cyan
        Write-Host "    Behavior Monitoring: $($status.BehaviorMonitoring)" -ForegroundColor Cyan
        Write-Host "    Script Scanning: $($status.ScriptScanning)" -ForegroundColor Cyan
        Write-Host "    IOAV Protection: $($status.IOAVProtection)" -ForegroundColor Cyan
    }
}

# Main script execution
try {
    # Display warning and get confirmation
    Write-Host "`n⚠️  WARNING: This script will disable Windows Defender." -ForegroundColor Red
    Write-Host "This should ONLY be used in isolated lab environments." -ForegroundColor Red
    Write-Host "Do NOT use this on production systems or systems with sensitive data." -ForegroundColor Red
    Write-Host "`nAre you sure you want to continue? (Y/N): " -NoNewline
    
    $confirmation = Read-Host
    if ($confirmation -notlike "Y*" -and $confirmation -notlike "y*") {
        Write-Host "`nSetup cancelled by user." -ForegroundColor Yellow
        exit 0
    }

    # Show current status
    Show-SectionHeader "Current Defender Status"
    Show-DefenderStatus

    # Backup current registry settings
    Show-SectionHeader "Backup Current Configuration"
    Write-Host "  Backing up Windows Defender registry settings..." -NoNewline
    $backupSuccess = Backup-DefenderRegistry
    if (-not $backupSuccess) {
        Write-Host "`n⚠️  Warning: Registry backup failed. Continuing anyway..." -ForegroundColor Yellow
    }

    # Method 1: Disable Windows Defender Service
    Show-SectionHeader "Method 1: Disable Windows Defender Service"
    Write-Host "  Stopping Windows Defender service..." -NoNewline
    try {
        Stop-Service -Name $ScriptConfig.DefenderServiceName -Force -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "  Disabling Windows Defender service..." -NoNewline
    try {
        Set-Service -Name $ScriptConfig.DefenderServiceName -StartupType Disabled -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 2: Terminate Windows Defender Processes
    Show-SectionHeader "Method 2: Terminate Defender Processes"
    foreach ($processName in $ScriptConfig.DefenderProcessNames) {
        Write-Host "  Terminating $processName processes..." -NoNewline
        try {
            $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($processes) {
                $processes | Stop-Process -Force -ErrorAction Stop
                Write-Host " ✓" -ForegroundColor Green
            } else {
                Write-Host " ℹ️  (No processes found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Method 3: Disable via PowerShell Cmdlets
    Show-SectionHeader "Method 3: Disable via PowerShell Cmdlets"
    Write-Host "  Disabling real-time protection..." -NoNewline
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "  Disabling behavior monitoring..." -NoNewline
    try {
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "  Disabling script scanning..." -NoNewline
    try {
        Set-MpPreference -DisableScriptScanning $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "  Disabling IOAV protection..." -NoNewline
    try {
        Set-MpPreference -DisableIOAVProtection $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "  Disabling intrusion prevention..." -NoNewline
    try {
        Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 4: Disable via Registry
    Show-SectionHeader "Method 4: Disable via Registry"
    Write-Host "  Setting registry keys to disable Defender..." -NoNewline
    try {
        # Create registry keys if they don't exist
        foreach ($regPath in $ScriptConfig.DefenderRegistryPaths) {
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
        }

        # Set disable registry values
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "DisableBlockAtFirstSeen" -Value 1 -Force -ErrorAction Stop

        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 5: Remove Scheduled Tasks
    Show-SectionHeader "Method 5: Remove Scheduled Tasks"
    foreach ($taskName in $ScriptConfig.DefenderScheduledTasks) {
        Write-Host "  Removing scheduled task: $taskName..." -NoNewline
        try {
            $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
            if ($task) {
                Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
                Write-Host " ✓" -ForegroundColor Green
            } else {
                Write-Host " ℹ️  (Task not found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Method 6: Disable via Group Policy (Registry)
    Show-SectionHeader "Method 6: Disable via Group Policy Settings"
    Write-Host "  Setting group policy registry keys..." -NoNewline
    try {
        # Ensure group policy paths exist
        foreach ($gpoPath in $ScriptConfig.DefenderGPOPaths) {
            if (-not (Test-Path $gpoPath)) {
                New-Item -Path $gpoPath -Force | Out-Null
            }
        }

        # Set group policy values
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiVirus" -Value 1 -Force -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Force -ErrorAction Stop

        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 7: Disable Tamper Protection
    Show-SectionHeader "Method 7: Disable Tamper Protection"
    Write-Host "  Disabling tamper protection..." -NoNewline
    try {
        # Check if tamper protection is available (Windows 10 1903+ / Windows 11)
        $tamperProtection = Get-MpComputerStatus | Select-Object -ExpandProperty IsTamperProtected
        if ($tamperProtection -ne $null) {
            Set-MpPreference -DisableTamperProtection $true -ErrorAction Stop
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host " ℹ️  (Tamper protection not available)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 8: Disable Cloud Protection
    Show-SectionHeader "Method 8: Disable Cloud Protection"
    Write-Host "  Disabling cloud-delivered protection..." -NoNewline
    try {
        Set-MpPreference -MAPSReporting 0 -ErrorAction Stop
        Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Method 9: Disable Automatic Sample Submission
    Show-SectionHeader "Method 9: Disable Automatic Sample Submission"
    Write-Host "  Disabling automatic sample submission..." -NoNewline
    try {
        Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Show final status
    Show-SectionHeader "Final Defender Status"
    Show-DefenderStatus

    # Success message
    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host "  ✅ Windows Defender Disabling Complete!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "`nWindows Defender has been disabled using multiple methods." -ForegroundColor Cyan
    Write-Host "The following changes were applied:" -ForegroundColor Cyan
    Write-Host "  • Service stopped and disabled" -ForegroundColor Cyan
    Write-Host "  • Processes terminated" -ForegroundColor Cyan
    Write-Host "  • Real-time protection disabled" -ForegroundColor Cyan
    Write-Host "  • Behavior monitoring disabled" -ForegroundColor Cyan
    Write-Host "  • Script scanning disabled" -ForegroundColor Cyan
    Write-Host "  • Registry keys set to disable" -ForegroundColor Cyan
    Write-Host "  • Scheduled tasks removed" -ForegroundColor Cyan
    Write-Host "  • Group policy settings applied" -ForegroundColor Cyan
    Write-Host "  • Tamper protection disabled" -ForegroundColor Cyan
    Write-Host "  • Cloud protection disabled" -ForegroundColor Cyan
    Write-Host "`n⚠️  IMPORTANT: " -ForegroundColor Red
    Write-Host "  • A registry backup was created: $($ScriptConfig.BackupFile)" -ForegroundColor Yellow
    Write-Host "  • To restore: reg import \"$($ScriptConfig.BackupFile)\"" -ForegroundColor Yellow
    Write-Host "  • System reboot may be required for all changes to take effect" -ForegroundColor Yellow
    Write-Host "  • Some changes may be reverted by Windows updates" -ForegroundColor Yellow
    Write-Host "`n==========================================`n" -ForegroundColor Green

} catch {
    # Error handling
    Write-Host "`n[!] Defender disabling failed with error:" -ForegroundColor Red
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nAttempting to restore original configuration..." -ForegroundColor Yellow
    
    # Restore registry if backup exists
    if (Test-Path $ScriptConfig.BackupFile) {
        Restore-DefenderRegistry -backupFile $ScriptConfig.BackupFile
    }
    
    Write-Host "`nPlease check the error message above and try again." -ForegroundColor Red
    Write-Host "Some manual intervention may be required." -ForegroundColor Red
    exit 1
}