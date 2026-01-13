<#
    Simple Windows Defender Disabler
    
    This script provides a simplified approach to disable Windows Defender
    for offensive security testing in isolated lab environments.
    
    WARNING: For EDUCATIONAL and RESEARCH purposes only.
    Only use in isolated lab environments on systems you own or have permission to test.
    
    Usage: Run as Administrator
#>

# Require Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges." -ForegroundColor Red
    exit 1
}

Write-Host "Windows Defender Disabler - FOR LAB ENVIRONMENTS ONLY" -ForegroundColor Red
Write-Host "This will disable Windows Defender using multiple methods."
Write-Host "Are you sure you want to continue? (Y/N): " -NoNewline

$confirmation = Read-Host
if ($confirmation -notlike "Y*" -and $confirmation -notlike "y*") {
    Write-Host "Setup cancelled."
    exit 0
}

# Method 1: Disable Windows Defender Service
Write-Host "Stopping Windows Defender service..."
try {
    Stop-Service -Name "WinDefend" -Force -ErrorAction Stop
    Set-Service -Name "WinDefend" -StartupType Disabled -ErrorAction Stop
    Write-Host "✓ Service disabled successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Service disable failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 2: Disable via PowerShell Cmdlets
Write-Host "Disabling real-time protection..."
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction Stop
    Set-MpPreference -DisableScriptScanning $true -ErrorAction Stop
    Set-MpPreference -DisableIOAVProtection $true -ErrorAction Stop
    Write-Host "✓ Real-time protection disabled" -ForegroundColor Green
} catch {
    Write-Host "✗ Real-time protection disable failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 3: Disable via Registry
Write-Host "Setting registry keys to disable Defender..."
try {
    # Create registry keys if they don't exist
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Set disable registry values
    Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 1 -Force -ErrorAction Stop
    Set-ItemProperty -Path "$regPath\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Force -ErrorAction Stop
    
    Write-Host "✓ Registry keys set successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Registry configuration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Show final status
Write-Host "Windows Defender has been disabled using multiple methods." -ForegroundColor Green
Write-Host "Some changes may require a system reboot to take full effect." -ForegroundColor Yellow
Write-Host "To restore: Enable the WinDefend service and reset registry keys." -ForegroundColor Yellow