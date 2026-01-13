# Windows 11 WinRM Setup Guide

## 🎯 Overview

This guide provides instructions for configuring Windows 11 to receive Ansible playbooks via WinRM (Windows Remote Management). The provided PowerShell script automates the entire setup process.

## 📥 Download the Script

Download the PowerShell script:

```bash
# From the offensive-windows-ansible repository
wget https://raw.githubusercontent.com/your-repo/offensive-windows-ansible/main/windows11-winrm-setup.ps1
```

Or copy it from the repository:
- **File:** `windows11-winrm-setup.ps1`
- **Location:** Root directory of the offensive-windows-ansible project

## 🚀 Quick Setup

### Method 1: Direct Execution (Recommended)

```powershell
# 1. Save the script to your Windows 11 machine
# 2. Open PowerShell as Administrator
# 3. Run the script
."windows11-winrm-setup.ps1"
```

### Method 2: Remote Execution

```powershell
# From another machine with PowerShell remoting enabled
Invoke-Command -ComputerName WIN11-VM -FilePath .\windows11-winrm-setup.ps1 -Credential (Get-Credential)
```

## 🔧 Manual Setup (Alternative)

If you prefer to configure WinRM manually, follow these steps:

### 1. Enable WinRM

```powershell
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"
```

### 2. Configure HTTPS Listener

```powershell
# Create self-signed certificate
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My

# Create HTTPS listener
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force
```

### 3. Configure WinRM Service

```powershell
Set-Service WinRM -StartupType Automatic
Start-Service WinRM
```

### 4. Configure Firewall

```powershell
# Allow WinRM HTTPS (port 5986)
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

# Allow WinRM HTTP (port 5985)
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
```

### 5. Set Execution Policy

```powershell
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
```

## 📋 What the Script Does

The `windows11-winrm-setup.ps1` script performs the following actions:

### 1. **Prerequisite Check**
- Verifies Administrator privileges
- Displays script header and configuration

### 2. **WinRM Configuration**
- Enables WinRM service
- Sets TrustedHosts to `*` (all hosts)
- Backs up original TrustedHosts value

### 3. **Certificate Setup**
- Creates self-signed certificate for the computer
- Uses the certificate for HTTPS encryption

### 4. **WinRM Listener**
- Creates HTTPS listener on port 5986
- Removes existing listeners if they exist
- Configures certificate-based authentication

### 5. **Service Configuration**
- Sets WinRM service to Automatic startup
- Starts the WinRM service
- Verifies service status

### 6. **Firewall Configuration**
- Cleans up existing WinRM firewall rules
- Adds new rules for HTTPS (5986) and HTTP (5985)
- Configures inbound traffic allowance

### 7. **Security Configuration**
- Sets PowerShell execution policy to Bypass
- Enables script execution for Ansible

### 8. **Connectivity Testing**
- Tests HTTPS and HTTP WinRM connectivity
- Provides detailed error messages if tests fail

### 9. **Configuration Summary**
- Displays all configured settings
- Shows certificate thumbprint
- Lists firewall rules and service status

### 10. **Ansible Test Command**
- Provides sample Ansible command for testing
- Shows proper connection parameters

## 🎨 Script Features

### Comprehensive Error Handling
- Catches and displays detailed error messages
- Attempts to restore original configuration on failure
- Provides clear guidance for troubleshooting

### Configuration Backup
- Backs up original TrustedHosts value
- Provides restoration function
- Preserves original settings

### Detailed Logging
- Color-coded output for easy reading
- Section headers for clear organization
- Success/failure indicators

### Connectivity Testing
- Tests both HTTPS and HTTP connectivity
- Provides immediate feedback
- Helps verify successful setup

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Issue: "Access Denied" or "Requires Administrator"
**Solution:** Run PowerShell as Administrator
```powershell
# Right-click PowerShell → Run as Administrator
```

#### Issue: WinRM Service Fails to Start
**Solution:** Check dependencies and restart
```powershell
Get-Service WinRM | Select-Object Status, DependentServices
Restart-Service WinRM -Force
```

#### Issue: Certificate Creation Fails
**Solution:** Check certificate store permissions
```powershell
# Verify you have permissions to LocalMachine\My store
certmgr.msc
```

#### Issue: Firewall Rules Not Created
**Solution:** Check firewall service status
```powershell
Get-Service MpsSvc | Start-Service
```

#### Issue: Ansible Connection Fails
**Solution:** Verify WinRM configuration
```powershell
winrm enumerate winrm/config/listener
Test-WSMan -ComputerName localhost
```

## 🛡️ Security Considerations

### TrustedHosts Configuration
- The script sets TrustedHosts to `*` (all hosts)
- **For production:** Consider restricting to specific IPs
- **After setup:** You can modify TrustedHosts for better security

### Self-Signed Certificate
- The script creates a self-signed certificate
- **For production:** Consider using a CA-signed certificate
- **Security:** Self-signed certificates are suitable for lab environments

### Execution Policy
- The script sets execution policy to Bypass
- **For production:** Consider using RemoteSigned or AllSigned
- **Security:** Bypass allows all scripts to run without signing

## 🔄 Reversing the Setup

To undo the WinRM configuration:

```powershell
# Restore original TrustedHosts (if you know the original value)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "original-value" -Force

# Remove WinRM listeners
Get-ChildItem WSMan:\LocalHost\Listener | Remove-Item -Recurse -Force

# Remove firewall rules
Get-NetFirewallRule -DisplayName "WinRM *" | Remove-NetFirewallRule -Confirm:$false

# Reset execution policy
Set-ExecutionPolicy Restricted -Scope LocalMachine -Force

# Stop and disable WinRM service
Stop-Service WinRM -Force
Set-Service WinRM -StartupType Manual
```

## 📚 Ansible Connection Examples

### Test WinRM Connectivity
```bash
ansible windows -i inventory.ini -m win_ping
```

### Run a Simple Command
```bash
ansible windows -i inventory.ini -m win_shell -a "Get-ComputerInfo"
```

### Gather Facts
```bash
ansible windows -i inventory.ini -m setup
```

## 🎯 Best Practices

### 1. **Use Specific TrustedHosts**
Instead of `*`, specify your Ansible control node IP:
```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.100" -Force
```

### 2. **Use HTTPS Only**
Disable HTTP listener for better security:
```powershell
Get-ChildItem WSMan:\LocalHost\Listener | Where-Object { $_.Keys -contains "Transport=HTTP" } | Remove-Item -Recurse -Force
```

### 3. **Monitor WinRM Logs**
Check WinRM event logs for issues:
```powershell
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -MaxEvents 20
```

### 4. **Regular Maintenance**
Update certificates and rotate credentials regularly.

## 📞 Support

For WinRM-specific issues:
- [Microsoft WinRM Documentation](https://docs.microsoft.com/en-us/windows/win32/winrm/portal)
- [PowerShell Remoting Guide](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/)

For Ansible Windows issues:
- [Ansible Windows Documentation](https://docs.ansible.com/ansible/latest/collections/ansible/windows/)
- [WinRM Connection Guide](https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html)

## 🎉 Next Steps

After completing the WinRM setup:

1. **Update your Ansible inventory** with the Windows 11 VM IP
2. **Test connectivity** with `ansible windows -i inventory.ini -m win_ping`
3. **Run the offensive tools setup** with the main playbook

```bash
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml
```

The script provides a complete, automated solution for preparing Windows 11 to receive Ansible playbooks, making it easy to deploy your offensive security toolkit! 🚀