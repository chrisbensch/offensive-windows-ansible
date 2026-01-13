#!/bin/bash

# test-setup.sh
# Test script to verify the offensive-windows-ansible setup

echo "=== Offensive Windows Ansible - Setup Test ==="
echo ""

# Check if Ansible is installed
echo "1. Checking Ansible installation..."
if command -v ansible &> /dev/null; then
    echo "✓ Ansible is installed: $(ansible --version | head -n 1)"
else
    echo "✗ Ansible is not installed. Please install Ansible first."
    exit 1
fi

# Check if Python is installed
echo ""
echo "2. Checking Python installation..."
if command -v python3 &> /dev/null; then
    echo "✓ Python is installed: $(python3 --version)"
else
    echo "✗ Python is not installed. Please install Python 3.8+"
    exit 1
fi

# Check if pywinrm is installed
echo ""
echo "3. Checking pywinrm installation..."
if python3 -c "import winrm" &> /dev/null; then
    echo "✓ pywinrm is installed"
else
    echo "✗ pywinrm is not installed. Installing..."
    pip install pywinrm
    if [ $? -eq 0 ]; then
        echo "✓ pywinrm installed successfully"
    else
        echo "✗ Failed to install pywinrm"
        exit 1
    fi
fi

# Check if required files exist
echo ""
echo "4. Checking required files..."
required_files=(
    "offensive-tools-playbook.yml"
    "chocolatey-config.yml"
    "mandiant-repo-config.yml"
    "windows11-inventory.ini"
    "main-offensive-setup.yml"
    "requirements.yml"
    "OFFENSIVE-TOOLS-SETUP.md"
    "vars/main-vars.yml"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file is missing"
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo ""
    echo "Missing files: ${missing_files[*]}"
    exit 1
fi

# Check Ansible collections
echo ""
echo "5. Checking Ansible collections..."
echo "Installing required collections..."
ansible-galaxy collection install -r requirements.yml
if [ $? -eq 0 ]; then
    echo "✓ Ansible collections installed successfully"
else
    echo "✗ Failed to install Ansible collections"
    exit 1
fi

# Test inventory file syntax
echo ""
echo "6. Testing inventory file syntax..."
if ansible-inventory -i windows11-inventory.ini --list &> /dev/null; then
    echo "✓ Inventory file syntax is valid"
else
    echo "✗ Inventory file has syntax errors"
    exit 1
fi

# Test playbook syntax
echo ""
echo "7. Testing playbook syntax..."
playbooks=(
    "offensive-tools-playbook.yml"
    "chocolatey-config.yml"
    "mandiant-repo-config.yml"
    "main-offensive-setup.yml"
)

for playbook in "${playbooks[@]}"; do
    if ansible-playbook -i windows11-inventory.ini "$playbook" --syntax-check &> /dev/null; then
        echo "✓ $playbook syntax is valid"
    else
        echo "✗ $playbook has syntax errors"
        exit 1
    fi
done

echo ""
echo "=== All tests passed! ==="
echo ""
echo "Next steps:"
echo "1. Update windows11-inventory.ini with your Windows 11 VM details"
echo "2. Configure WinRM on your Windows 11 VM (see OFFENSIVE-TOOLS-SETUP.md)"
echo "3. Test WinRM connectivity: ansible windows11 -i windows11-inventory.ini -m win_ping"
echo "4. Run the main playbook: ansible-playbook -i windows11-inventory.ini main-offensive-setup.yml"
echo ""
echo "For detailed instructions, see OFFENSIVE-TOOLS-SETUP.md"