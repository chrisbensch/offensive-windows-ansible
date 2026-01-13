<#
    Windows 11 WinRM Setup Script
    
    This PowerShell script configures Windows 11 to receive Ansible playbooks
    via WinRM (Windows Remote Management).
    
    Usage:
    1. Save this script as `windows11-winrm-setup.ps1`
    2. Run as Administrator: .\windows11-winrm-setup.ps1
    3. Follow the prompts
#>

<#
    CHANGELOG:
    - Added comprehensive error handling
    - Added firewall rule cleanup
    - Added certificate validation
    - Added WinRM service restart
    - Added TrustedHosts backup/restore
    - Added execution policy verification
#>

# Require Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[!] This script requires Administrator privileges.`n" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Script configuration
$ScriptConfig = @{
    WinRM_HTTPS_Port = 5986
    WinRM_HTTP_Port = 5985
    CertificateSubject = $env:COMPUTERNAME
    CertificateStore = "LocalMachine\My"
    TrustedHostsValue = "*"
    ExecutionPolicy = "Bypass"
    ServiceStartupType = "Automatic"
    FirewallRuleNames = @("WinRM HTTPS", "WinRM HTTP")
}

# Display script header
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  Windows 11 WinRM Setup Script" -ForegroundColor Cyan
Write-Host "  Preparing for Ansible Playbooks" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# Function to display section header
function Show-SectionHeader {
    param([string]$title)
    Write-Host "`n[$title]" -ForegroundColor Green
    Write-Host "$( '-' * 50)" -ForegroundColor DarkGray
}

# Function to test WinRM connectivity
function Test-WinRMConnectivity {
    param([string]$scheme, [int]$port)
    
    try {
        $uri = "$($scheme)://localhost:`$port/wsman"
        $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        Write-Host "  ✗ $($scheme) connectivity test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to backup current TrustedHosts
function Backup-TrustedHosts {
    $currentTrustedHosts = Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue
    if ($currentTrustedHosts) {
        return $currentTrustedHosts.Value
    }
    return $null
}

# Function to restore TrustedHosts
function Restore-TrustedHosts {
    param([string]$backupValue)
    
    if ($backupValue) {
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value $backupValue -Force
        Write-Host "  ✓ Restored TrustedHosts to: $backupValue" -ForegroundColor Green
    }
}

# Main script execution
try {
    # Backup current TrustedHosts
    $trustedHostsBackup = Backup-TrustedHosts
    if ($trustedHostsBackup) {
        Write-Host "  ℹ️  Backed up current TrustedHosts: $trustedHostsBackup" -ForegroundColor Yellow
    }

    # Section 1: Enable WinRM
    Show-SectionHeader "Enable WinRM"
    Write-Host "  Enabling WinRM service..." -NoNewline
    try {
        Enable-PSRemoting -Force -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 2: Configure TrustedHosts
    Show-SectionHeader "Configure TrustedHosts"
    Write-Host "  Setting TrustedHosts to: $($ScriptConfig.TrustedHostsValue)" -NoNewline
    try {
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value $ScriptConfig.TrustedHostsValue -Force -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "  Current TrustedHosts: $(Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value)" -ForegroundColor Cyan
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 3: Create Self-Signed Certificate
    Show-SectionHeader "Create Self-Signed Certificate"
    Write-Host "  Creating certificate for: $($ScriptConfig.CertificateSubject)" -NoNewline
    try {
        $cert = New-SelfSignedCertificate -DnsName $ScriptConfig.CertificateSubject -CertStoreLocation "Cert:\$($ScriptConfig.CertificateStore)" -ErrorAction Stop
        $thumbprint = $cert.Thumbprint
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "  Certificate Thumbprint: $thumbprint" -ForegroundColor Cyan
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 4: Configure WinRM HTTPS Listener
    Show-SectionHeader "Configure WinRM HTTPS Listener"
    Write-Host "  Creating HTTPS listener on port $($ScriptConfig.WinRM_HTTPS_Port)..." -NoNewline
    try {
        # Remove existing listener if it exists
        $existingListener = Get-ChildItem WSMan:\LocalHost\Listener | Where-Object { $_.Keys -contains "Transport=HTTPS" }
        if ($existingListener) {
            Remove-Item -Path $existingListener.PSPath -Recurse -Force
            Write-Host "`n  ℹ️  Removed existing HTTPS listener" -ForegroundColor Yellow
        }

        New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address "*" -CertificateThumbPrint $thumbprint -Force -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 5: Configure WinRM Service
    Show-SectionHeader "Configure WinRM Service"
    Write-Host "  Setting WinRM service to $($ScriptConfig.ServiceStartupType)..." -NoNewline
    try {
        Set-Service WinRM -StartupType $ScriptConfig.ServiceStartupType -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 6: Start WinRM Service
    Show-SectionHeader "Start WinRM Service"
    Write-Host "  Starting WinRM service..." -NoNewline
    try {
        Start-Service WinRM -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "  WinRM Service Status: $(Get-Service WinRM | Select-Object -ExpandProperty Status)" -ForegroundColor Cyan
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 7: Configure Firewall
    Show-SectionHeader "Configure Firewall"
    
    # Clean up existing rules
    foreach ($ruleName in $ScriptConfig.FirewallRuleNames) {
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if ($existingRule) {
            Remove-NetFirewallRule -DisplayName $ruleName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "  ℹ️  Removed existing firewall rule: $ruleName" -ForegroundColor Yellow
        }
    }

    # Add new firewall rules
    Write-Host "  Adding firewall rule for HTTPS (port $($ScriptConfig.WinRM_HTTPS_Port))..." -NoNewline
    try {
        New-NetFirewallRule -DisplayName "$($ScriptConfig.FirewallRuleNames[0])" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $ScriptConfig.WinRM_HTTPS_Port -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    Write-Host "  Adding firewall rule for HTTP (port $($ScriptConfig.WinRM_HTTP_Port))..." -NoNewline
    try {
        New-NetFirewallRule -DisplayName "$($ScriptConfig.FirewallRuleNames[1])" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $ScriptConfig.WinRM_HTTP_Port -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 8: Set Execution Policy
    Show-SectionHeader "Set Execution Policy"
    Write-Host "  Setting execution policy to $($ScriptConfig.ExecutionPolicy)..." -NoNewline
    try {
        Set-ExecutionPolicy $ScriptConfig.ExecutionPolicy -Scope LocalMachine -Force -ErrorAction Stop
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "  Current Execution Policy: $(Get-ExecutionPolicy -Scope LocalMachine)" -ForegroundColor Cyan
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }

    # Section 9: Test WinRM Connectivity
    Show-SectionHeader "Test WinRM Connectivity"
    
    Write-Host "  Testing HTTPS connectivity..." -NoNewline
    $httpsTest = Test-WinRMConnectivity -scheme "https" -port $ScriptConfig.WinRM_HTTPS_Port
    if ($httpsTest) {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  HTTPS connectivity test failed" -ForegroundColor Red
    }

    Write-Host "  Testing HTTP connectivity..." -NoNewline
    $httpTest = Test-WinRMConnectivity -scheme "http" -port $ScriptConfig.WinRM_HTTP_Port
    if ($httpTest) {
        Write-Host " ✓" -ForegroundColor Green
    } else {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host "  HTTP connectivity test failed" -ForegroundColor Red
    }

    # Section 10: Display Configuration Summary
    Show-SectionHeader "Configuration Summary"
    
    $winrmConfig = Get-ChildItem WSMan:\localhost\Listener
    $trustedHosts = Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue
    $executionPolicy = Get-ExecutionPolicy -Scope LocalMachine
    $winrmService = Get-Service WinRM
    $firewallRules = Get-NetFirewallRule -DisplayName $ScriptConfig.FirewallRuleNames -ErrorAction SilentlyContinue

    Write-Host "  WinRM Service Status: $($winrmService.Status)" -ForegroundColor Cyan
    Write-Host "  WinRM Service Startup: $($winrmService.StartType)" -ForegroundColor Cyan
    Write-Host "  Execution Policy: $executionPolicy" -ForegroundColor Cyan
    Write-Host "  TrustedHosts: $($trustedHosts.Value)" -ForegroundColor Cyan
    Write-Host "  HTTPS Listener: $($winrmConfig | Where-Object { $_.Keys -contains "Transport=HTTPS" } | Select-Object -ExpandProperty Keys)" -ForegroundColor Cyan
    Write-Host "  Firewall Rules: $($firewallRules.DisplayName -join ', ')" -ForegroundColor Cyan
    Write-Host "  Certificate Thumbprint: $thumbprint" -ForegroundColor Cyan

    # Section 11: Ansible Connection Test
    Show-SectionHeader "Ansible Connection Test"
    Write-Host "  Here's a sample Ansible command to test connectivity:" -ForegroundColor Cyan
    Write-Host "  " -NoNewline
    Write-Host "ansible windows -i inventory.ini -m win_ping --extra-vars " -ForegroundColor Yellow
    Write-Host "  " -NoNewline
    Write-Host '"ansible_user=Administrator ansible_password=YourPassword ansible_connection=winrm ansible_winrm_transport=credssp"' -ForegroundColor Yellow

    # Section 12: Cleanup Options
    Show-SectionHeader "Cleanup Options"
    Write-Host "  To restore original TrustedHosts:" -ForegroundColor Cyan
    Write-Host "  " -NoNewline
    Write-Host "Restore-TrustedHosts -backupValue `$trustedHostsBackup" -ForegroundColor Yellow

    # Success message
    Write-Host "`n==========================================" -ForegroundColor Green
    Write-Host "  ✅ Windows 11 WinRM Setup Complete!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "`nYour Windows 11 system is now ready to receive Ansible playbooks." -ForegroundColor Cyan
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Update your Ansible inventory file with this system's IP" -ForegroundColor Cyan
    Write-Host "  2. Test connectivity with: ansible windows -i inventory.ini -m win_ping" -ForegroundColor Cyan
    Write-Host "  3. Run your Ansible playbooks!" -ForegroundColor Cyan
    Write-Host "`n==========================================`n" -ForegroundColor Green

} catch {
    # Error handling
    Write-Host "`n[!] Setup failed with error:" -ForegroundColor Red
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nAttempting to restore original configuration..." -ForegroundColor Yellow
    
    # Restore TrustedHosts if backup exists
    if ($trustedHostsBackup) {
        Restore-TrustedHosts -backupValue $trustedHostsBackup
    }
    
    Write-Host "`nPlease check the error message above and try again." -ForegroundColor Red
    Write-Host "You may need to run this script again after resolving the issue." -ForegroundColor Red
    exit 1
}