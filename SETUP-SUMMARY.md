# Offensive Windows Ansible - Setup Summary

## ✅ Completed Tasks

### 1. **Created Comprehensive Ansible Playbooks**
- **`offensive-tools-playbook.yml`**: Main playbook for installing offensive security tools
- **`chocolatey-config.yml`**: Chocolatey package manager configuration
- **`mandiant-repo-config.yml`**: Mandiant VM packages repository setup
- **`main-offensive-setup.yml`**: Complete setup playbook combining all components

### 2. **Configured Chocolatey Package Manager**
- Automatic installation and configuration
- Global settings for offensive tool installation
- Security settings for package installation
- Environment variables and directory structure

### 3. **Mandiant Repository Integration**
- Added Mandiant VM packages repository as Chocolatey source
- Repository connectivity testing
- Mandiant-specific tools installation
- Priority configuration for package sources

### 4. **Windows 11 VM Configuration**
- **`windows11-inventory.ini`**: Complete inventory file with WinRM settings
- Performance optimization for large installations
- Network and security configuration
- System requirements and prerequisites

### 5. **Offensive Tools Installation**
- **20+ Offensive Security Tools**: Sysinternals, Wireshark, Nmap, Metasploit, Burp Suite, Ghidra, IDA, Volatility, Autopsy, etc.
- **Development Tools**: Git, Python, PowerShell Core, Visual Studio, SDKs, runtimes
- **PowerShell Modules**: PowerSploit, Nishang, Empire, BloodHound, Mimikatz, etc.
- **WSL Configuration**: Windows Subsystem for Linux setup
- **Directory Structure**: Organized tools directory with proper PATH configuration

### 6. **Testing and Validation**
- All YAML files validated for correct syntax
- Playbook structure verified
- Inventory file tested
- Requirements file created for Ansible collections

## 📁 Files Created

### Playbooks:
- `offensive-tools-playbook.yml` - Main offensive tools installation
- `chocolatey-config.yml` - Chocolatey configuration
- `mandiant-repo-config.yml` - Mandiant repository setup
- `main-offensive-setup.yml` - Complete setup workflow

### Configuration:
- `windows11-inventory.ini` - Windows 11 VM inventory
- `requirements.yml` - Ansible collection requirements
- `vars/main-vars.yml` - Main variables and settings

### Documentation:
- `OFFENSIVE-TOOLS-SETUP.md` - Complete setup guide
- `SETUP-SUMMARY.md` - This summary file
- `test-setup.sh` - Setup validation script

## 🚀 Quick Start Guide

### 1. Update Inventory File
Edit `windows11-inventory.ini` with your Windows 11 VM details:
```ini
[windows11]
windows11_vm ansible_host=YOUR_VM_IP_ADDRESS

[windows11:vars]
ansible_user=YOUR_ADMIN_USERNAME
ansible_password=YOUR_ADMIN_PASSWORD
```

### 2. Configure Windows 11 VM
Run the PowerShell commands from `OFFENSIVE-TOOLS-SETUP.md` to enable WinRM.

### 3. Install Ansible Collections
```bash
ansible-galaxy collection install -r requirements.yml
```

### 4. Run the Complete Setup
```bash
ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml
```

### 5. Or Run Step-by-Step
```bash
# Configure Chocolatey
ansible-playbook -i windows11-inventory.ini chocolatey-config.yml

# Configure Mandiant repository
ansible-playbook -i windows11-inventory.ini mandiant-repo-config.yml

# Install offensive tools
ansible-playbook -i windows11-inventory.ini offensive-tools-playbook.yml
```

## 🎯 Key Features

### Comprehensive Toolset
- **Network Analysis**: Wireshark, Nmap, TCPView
- **Exploitation**: Metasploit, Burp Suite, PowerSploit
- **Reverse Engineering**: Ghidra, IDA Free, Radare2
- **Forensics**: Volatility, Autopsy, FTK Imager
- **System Analysis**: Sysinternals Suite, Process Hacker
- **Red Team Tools**: Empire, PoshC2, BloodHound

### Automated Configuration
- Chocolatey package manager setup
- Mandiant repository integration
- Windows Subsystem for Linux (WSL)
- PowerShell modules installation
- System optimization for offensive operations

### Professional Structure
- Modular playbook design
- Comprehensive error handling
- Retry mechanisms for unreliable installations
- Detailed logging and reporting
- System restore points for safety

## 🔧 Customization Options

### Add More Tools
Edit the `offensive_tools` list in `vars/main-vars.yml`:
```yaml
offensive_tools:
  - name: "new-tool-name"
    description: "Description of the tool"
    category: "category"
```

### Configure Security Settings
Adjust `disable_defender` and other security settings in `vars/main-vars.yml`.

### Proxy Configuration
Uncomment and configure proxy settings in the inventory file.

## 📚 Documentation

For complete setup instructions, troubleshooting, and advanced configuration, refer to:
- **`OFFENSIVE-TOOLS-SETUP.md`** - Complete setup guide
- **`SETUP-SUMMARY.md`** - This summary

## 🎉 Next Steps

1. **Update inventory file** with your Windows 11 VM details
2. **Configure WinRM** on your Windows 11 VM
3. **Test connectivity** with `ansible windows11 -i windows11-inventory.ini -m win_ping`
4. **Run the setup** with `ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml`
5. **Verify installation** and start using your offensive security tools!

## 💡 Tips

- Use this in **isolated lab environments** only
- Store sensitive credentials in **Ansible Vault**
- Review **security considerations** in the setup guide
- Customize the toolset based on your **specific requirements**
- Consider **resource requirements** (50GB+ disk, 8GB+ RAM)

## 🔒 Security Reminder

This setup is designed for **educational and research purposes** only. Always:
- Use on systems you **own or have permission** to test
- Operate in **isolated network environments**
- Comply with **all applicable laws and regulations**
- Obtain proper **authorization** before testing

Enjoy your new offensive security toolkit! 🚀