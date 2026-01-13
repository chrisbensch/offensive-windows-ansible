# Offensive Windows Ansible

![Offensive Windows Ansible](https://img.shields.io/badge/Ansible-Offensive%20Windows-blue)
![Chocolatey](https://img.shields.io/badge/Chocolatey-Installed-green)
![Mandiant](https://img.shields.io/badge/Mandiant-Repository-orange)

## 🎯 Overview

**Offensive Windows Ansible** is a comprehensive Ansible-based solution for automating the installation of offensive security tools on Windows 11 virtual machines. This project leverages Chocolatey package manager and Mandiant's VM packages repository to deploy a complete offensive security toolkit.

## 🚀 Quick Start

### Prerequisites

- **Ansible Control Node:** Python 3.8+, Ansible 2.10+, `pywinrm`
- **Windows 11 Target:** Windows 11 Pro/Enterprise, Administrator privileges
- **Resources:** 50GB+ disk space, 8GB+ RAM, Internet connectivity

### Step 1: Prepare Windows 11 VM

Run the PowerShell setup script on your Windows 11 VM:

```powershell
# Download and run the WinRM setup script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-repo/offensive-windows-ansible/main/windows11-winrm-setup.ps1" -OutFile "windows11-winrm-setup.ps1"
."windows11-winrm-setup.ps1"
```

Or use the local script:
```powershell
# Copy windows11-winrm-setup.ps1 to your Windows 11 VM
# Open PowerShell as Administrator
."windows11-winrm-setup.ps1"
```

### Step 2: Install Ansible Collections

```bash
# Clone the repository
git clone https://github.com/your-repo/offensive-windows-ansible.git
cd offensive-windows-ansible

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

### Step 3: Update Inventory File

```bash
# Edit windows11-inventory.ini with your Windows 11 VM details
cp windows11-inventory.ini.example windows11-inventory.ini
# Edit the file with your VM IP, username, and password
```

### Step 4: Test Connectivity

```bash
ansible windows11 -i windows11-inventory.ini -m win_ping
```

### Step 5: Run the Complete Setup

```bash
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml
```

## 📦 Components

### Playbooks

| Playbook | Description |
|----------|-------------|
| `main-offensive-setup.yml` | Complete setup workflow |
| `offensive-tools-playbook.yml` | Offensive tools installation |
| `chocolatey-config.yml` | Chocolatey configuration |
| `mandiant-repo-config.yml` | Mandiant repository setup |

### Configuration Files

| File | Description |
|------|-------------|
| `windows11-inventory.ini` | Windows 11 VM inventory |
| `windows11-winrm-setup.ps1` | PowerShell WinRM setup script |
| `disable-windows-defender.ps1` | PowerShell Defender disable script |
| `requirements.yml` | Ansible collection requirements |
| `vars/main-vars.yml` | Main variables and settings |

### Documentation

| File | Description |
|------|-------------|
| `OFFENSIVE-TOOLS-SETUP.md` | Complete setup guide |
| `SETUP-SUMMARY.md` | Quick reference summary |
| `WINRM-SETUP-GUIDE.md` | WinRM configuration guide |
| `DEFENDER-DISABLE-GUIDE.md` | Defender disable guide |

## 🔧 Setup Instructions

### 1. Configure Windows 11 VM

Run these PowerShell commands as Administrator on your Windows 11 VM:

```powershell
# Enable WinRM
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# Configure WinRM for HTTPS
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force

# Configure WinRM service
Set-Service WinRM -StartupType Automatic
Start-Service WinRM

# Open firewall ports
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# Set execution policy
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
```

### 2. Update Inventory File

Edit `windows11-inventory.ini` with your Windows 11 VM details:

```ini
[windows11]
windows11_vm ansible_host=YOUR_VM_IP_ADDRESS

[windows11:vars]
ansible_user=Administrator
ansible_password=YourStrongPassword123!
ansible_connection=winrm
ansible_port=5986
ansible_winrm_scheme=https
ansible_winrm_transport=credssp
```

### 3. Test Connectivity

```bash
ansible windows11 -i windows11-inventory.ini -m win_ping
```

### 4. Run the Setup

```bash
# Complete setup (recommended)
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml

# Or step-by-step
ansible-playbook -i windows11-inventory.ini chocolatey-config.yml
ansible-playbook -i windows11-inventory.ini mandiant-repo-config.yml
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml
```

## 🛠️ Tools Installed

### Offensive Security Tools

| Category | Tools |
|----------|-------|
| **Network Analysis** | Wireshark, Nmap, TCPView, Sysinternals Suite |
| **Exploitation** | Metasploit, Burp Suite, PowerSploit, Nishang |
| **Reverse Engineering** | Ghidra, IDA Free, Radare2 |
| **Forensics** | Volatility, Autopsy, FTK Imager, Regshot |
| **System Analysis** | Process Hacker, Process Monitor/Explorer, Autoruns |
| **Red Team** | Empire, PoshC2, BloodHound, Mimikatz |

### Development Environment

- **Languages:** Python, PowerShell Core, Go, Ruby, Node.js
- **Tools:** Git, Visual Studio Build Tools, Windows SDK
- **Runtimes:** .NET 6.0, OpenJDK
- **Containers:** Docker Desktop

### System Configuration

- **Windows Subsystem for Linux (WSL)**
- **PowerShell Modules** for offensive operations
- **Organized directory structure** for tools
- **System PATH configuration**
- **Desktop shortcuts** for common tools
- **Windows Defender management** (optional for lab environments)

## 🎨 Customization

### Add More Tools

Edit `vars/main-vars.yml`:

```yaml
offensive_tools:
  - name: "new-tool-name"
    description: "Description of the tool"
    category: "category"
```

### Configuration Options

```yaml
# vars/main-vars.yml
disable_defender: false  # Set to true for lab environments
disable_uac: false       # Disable User Account Control
reboot_required: true    # Automatic reboot if needed
```

### Proxy Configuration

Uncomment in `windows11-inventory.ini`:

```ini
chocolatey_proxy=http://your-proxy:8080
chocolatey_proxy_username=your_username
chocolatey_proxy_password=your_password
```

## 🛡️ Windows Defender Management

### Disabling for Lab Environments

For offensive security testing in isolated lab environments, you can disable Windows Defender:

```powershell
# Download and run the comprehensive disable script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-repo/offensive-windows-ansible/main/disable-windows-defender.ps1" -OutFile "disable-windows-defender.ps1"
."disable-windows-defender.ps1"
```

**⚠️ WARNING:** Only disable Windows Defender in isolated lab environments. This significantly reduces system security.

### Features

- **9 Comprehensive Methods:** Service control, process termination, PowerShell cmdlets, registry configuration, scheduled task removal, group policy settings, tamper protection, cloud protection, and sample submission
- **Automatic Backup:** Creates registry backup for easy restoration
- **Verification:** Shows before/after status
- **Error Handling:** Comprehensive error handling with rollback
- **Color-Coded Output:** Easy to read status information

### Restoration

```powershell
# Restore from backup (created automatically by the script)
reg import "C:\path\to\backup.reg"
Restart-Service -Name "WinDefend"
```

### Integration with Ansible

Add to your playbook:
```yaml
- name: Disable Windows Defender for lab environment
  win_shell: |
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-repo/offensive-windows-ansible/main/disable-windows-defender.ps1" -OutFile "C:\Windows\Temp\disable-defender.ps1"
    C:\Windows\Temp\disable-defender.ps1 -NonInteractive -Force
  args:
    executable: powershell.exe
  when: disable_defender | default(false) | bool
  tags: [defender, security]
```

## 🔍 Troubleshooting

### Common Issues

1. **WinRM Connection Failed**
   - Verify WinRM is properly configured
   - Check firewall settings
   - Ensure correct credentials

2. **Chocolatey Installation Failed**
   - Check internet connectivity
   - Verify PowerShell execution policy
   - Try with `--become` flag

3. **Package Installation Failed**
   - Some packages may require API keys
   - Check package availability
   - Try with `--ignore-errors` flag

### Debugging

```bash
# Verbose output
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml -vvv

# Step-by-step execution
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml --step

# Check specific host
ansible windows11 -i windows11-inventory.ini -m setup
```

## 📚 Documentation

- **Complete Setup Guide:** [`OFFENSIVE-TOOLS-SETUP.md`](OFFENSIVE-TOOLS-SETUP.md)
- **Quick Reference:** [`SETUP-SUMMARY.md`](SETUP-SUMMARY.md)
- **Ansible Collections:** [`requirements.yml`](requirements.yml)

## 🔒 Security Considerations

⚠️ **Important Security Notes:**

- **Lab Environment Only:** Use in isolated networks
- **Credentials:** Store sensitive data in Ansible Vault
- **Legal Compliance:** Only use on authorized systems
- **Detection:** Many tools are detected by AV/EDR solutions

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

## 📜 License

This project is provided for **educational and research purposes** only. Use responsibly and ethically.

## 🙏 Acknowledgments

- **Mandiant** for the VM packages repository
- **Chocolatey** community for the package manager
- **Ansible** team for the automation framework
- **Offensive Security** community for tool development

## 📞 Support

For issues with Mandiant packages:
- [Mandiant VM Packages](https://www.myget.org/F/vm-packages/api/v2)
- [Mandiant Documentation](https://www.mandiant.com/resources)

For Ansible Windows issues:
- [Ansible Windows Docs](https://docs.ansible.com/ansible/latest/collections/ansible/windows/)
- [Community Windows Collection](https://github.com/ansible-collections/community.windows)

## 🎉 Getting Started

1. **Update inventory** with your Windows 11 VM details
2. **Configure WinRM** on your Windows 11 VM
3. **Test connectivity** with `win_ping`
4. **Run the setup** and enjoy your offensive toolkit!

```bash
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml
```

🚀 **Happy Hacking!** (Ethically and Responsibly) 🚀