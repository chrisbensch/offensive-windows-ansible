<#
    Minimal Windows Defender Disabler
    
    This script provides the most reliable method to disable Windows Defender
    for offensive security testing in isolated lab environments.
    
    WARNING: For EDUCATIONAL and RESEARCH purposes only.
    Only use in isolated lab environments on systems you own or have permission to test.
    
    Usage: Run as Administrator
#>

# Require Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges."
    exit 1
}

Write-Host "Windows Defender Disabler - FOR LAB ENVIRONMENTS ONLY"
Write-Host "This will disable Windows Defender using registry settings."
Write-Host "Are you sure you want to continue? (Y/N): "

$confirmation = Read-Host
if ($confirmation -notlike "Y*" -and $confirmation -notlike "y*") {
    Write-Host "Setup cancelled."
    exit 0
}

# Disable Windows Defender using registry (most reliable method)
try {
    # Create registry path if it doesn't exist
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Set the key to disable Windows Defender
    Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 1 -Force
    
    Write-Host "Windows Defender has been disabled via registry."
    Write-Host "A system reboot may be required for changes to take full effect."
    Write-Host "To restore: Remove the DisableAntiSpyware registry value or set it to 0."
    
} catch {
    Write-Host "Error disabling Windows Defender: $($_.Exception.Message)"
    Write-Host "Please check your permissions and try again."
}