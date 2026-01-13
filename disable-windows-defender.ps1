# Simple Windows Defender Disabler
# Run as Administrator

# Check admin rights
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run as Administrator"
    exit
}

# Disable Defender service
try {
    Stop-Service WinDefend -Force
    Set-Service WinDefend -StartupType Disabled
    Write-Host "Service disabled"
} catch {
    Write-Host "Service disable failed: $_"
}

# Disable real-time protection
try {
    Set-MpPreference -DisableRealtimeMonitoring 1
    Write-Host "Real-time protection disabled"
} catch {
    Write-Host "Real-time protection disable failed: $_"
}

Write-Host "Done - some changes may require reboot"