# Offensive Windows Ansible - Setup Guide

## Overview

This project provides Ansible playbooks to automate the installation of offensive security tools on Windows 11 virtual machines using Chocolatey and Mandiant's VM packages repository.

## Prerequisites

### On the Ansible Control Node:
- Python 3.8+
- Ansible 2.10+
- `pywinrm` Python package
- Windows VM with WinRM properly configured

### On the Windows 11 Target VM:
- Windows 11 Pro/Enterprise (22H2 recommended)
- Administrator privileges
- WinRM service enabled and configured
- Network connectivity to the internet
- At least 50GB free disk space
- 8GB+ RAM recommended
- Virtualization extensions enabled (for WSL)

## Setup Instructions

### 1. Install Ansible and Dependencies

```bash
# Install Ansible and required Python packages
python -m pip install ansible pywinrm

# Install Windows-specific Ansible collections
ansible-galaxy collection install community.windows
ansible-galaxy collection install ansible.windows
```

### 2. Configure Windows 11 VM for WinRM

Run the following PowerShell commands on your Windows 11 VM (as Administrator):

```powershell
# Enable WinRM
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# Configure WinRM for HTTPS
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My
$thumbprint = $cert.Thumbprint

New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $thumbprint -Force

# Configure WinRM service
Set-Service WinRM -StartupType Automatic
Start-Service WinRM

# Open firewall ports
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# Set execution policy
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
```

### 3. Update Inventory File

Edit `windows11-inventory.ini` with your Windows 11 VM details:

```ini
[windows11]
windows11_vm ansible_host=YOUR_VM_IP_ADDRESS

[windows11:vars]
ansible_user=YOUR_ADMIN_USERNAME
ansible_password=YOUR_ADMIN_PASSWORD
```

### 4. Test WinRM Connectivity

```bash
# Test basic WinRM connectivity
ansible windows11 -i windows11-inventory.ini -m win_ping

# Test with explicit credentials
ansible windows11 -i windows11-inventory.ini -m win_ping --extra-vars "ansible_user=Administrator ansible_password=YourPassword"
```

## Running the Playbooks

### Option 1: Complete Installation (Recommended)

```bash
# Run the complete offensive tools installation
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml
```

### Option 2: Step-by-Step Installation

```bash
# Step 1: Configure Chocolatey
ansible-playbook -i windows11-inventory.ini chocolatey-config.yml

# Step 2: Configure Mandiant repository
ansible-playbook -i windows11-inventory.ini mandiant-repo-config.yml

# Step 3: Install offensive tools
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml
```

## Playbook Components

### 1. Chocolatey Configuration (`chocolatey-config.yml`)
- Installs and configures Chocolatey package manager
- Sets up directories and environment variables
- Configures security settings for package installation

### 2. Mandiant Repository (`mandiant-repo-config.yml`)
- Adds Mandiant VM packages repository as a Chocolatey source
- Tests repository connectivity
- Installs Mandiant-specific tools

### 3. Offensive Tools Installation (`offensive-tools-playbook.yml`)
- Installs comprehensive set of offensive security tools
- Configures WSL for Linux tooling
- Installs PowerShell modules for red team operations
- Creates directory structure and shortcuts

## Tools Installed

### Core Offensive Tools:
- **Sysinternals Suite** - Advanced Windows utilities
- **Wireshark** - Network protocol analyzer
- **Nmap** - Network mapper and scanner
- **Metasploit** - Penetration testing framework
- **Burp Suite** - Web application security testing
- **Ghidra** - Software reverse engineering
- **IDA Free** - Interactive Disassembler
- **Radare2** - Reverse engineering framework
- **Volatility** - Memory forensics
- **Autopsy** - Digital forensics platform
- **FTK Imager** - Forensic imaging tool
- **Process Hacker** - Advanced process viewer
- **Process Monitor/Explorer** - System monitoring

### Development Tools:
- Git, Python, PowerShell Core
- Visual Studio Build Tools
- Windows SDK
- .NET Runtime, OpenJDK, Go, Ruby, Node.js
- Docker Desktop

### PowerShell Modules:
- PowerSploit, Nishang, Empire
- PoshC2, Invoke-Obfuscation
- Atomic Red Team, BloodHound
- PowerView, PowerUp, Mimikatz

## Customization

### Adding More Tools

Edit the `offensive_tools` list in `offensive-tools-playbook.yml`:

```yaml
offensive_tools:
  - name: "new-tool-name"
    description: "Description of the tool"
```

### Proxy Configuration

Uncomment and configure proxy settings in the inventory file:

```ini
chocolatey_proxy=http://your-proxy:8080
chocolatey_proxy_username=your_username
chocolatey_proxy_password=your_password
```

## Troubleshooting

### Common Issues:

1. **WinRM Connection Failed**:
   - Verify WinRM is properly configured on Windows
   - Check firewall settings
   - Ensure correct credentials in inventory file

2. **Chocolatey Installation Failed**:
   - Check internet connectivity
   - Verify PowerShell execution policy
   - Try running with `--become` flag

3. **Package Installation Failed**:
   - Some Mandiant packages may require API keys
   - Check package availability in the repository
   - Try with `--ignore-errors` flag

### Debugging:

```bash
# Verbose output
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml -vvv

# Step-by-step execution
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml --step

# Check specific host
ansible windows11 -i windows11-inventory.ini -m setup
```

## Security Considerations

- **Credentials**: Store sensitive credentials in Ansible Vault
- **Network**: Use this in isolated lab environments only
- **Tools**: Many installed tools are detected by AV/EDR solutions
- **Legal**: Only use on systems you own or have permission to test

## Maintenance

### Updating Tools:

```bash
ansible-playbook -i windows11-inventory.ini update-tools.yml
```

### Cleaning Up:

```bash
ansible-playbook -i windows11-inventory.ini cleanup-tools.yml
```

## License

This project is provided for educational and research purposes only. Use responsibly and ethically.

## Support

For issues with Mandiant packages, refer to:
- Mandiant VM Packages: https://www.myget.org/F/vm-packages/api/v2
- Mandiant Documentation: https://www.mandiant.com/resources

For Ansible Windows issues:
- Ansible Windows Documentation: https://docs.ansible.com/ansible/latest/collections/ansible/windows/
- Community Windows Collection: https://github.com/ansible-collections/community.windows