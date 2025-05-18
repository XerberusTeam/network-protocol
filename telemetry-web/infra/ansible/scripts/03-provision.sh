#!/bin/bash -ex

# Get script directory path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$(cd "$SCRIPT_DIR"/.. && pwd)"
INFRA_DIR="$(cd "$ANSIBLE_DIR"/.. && pwd)"

# Display header
echo "=========================================================="
echo "  Running Ansible Provisioning on VM via Local Execution"
echo "=========================================================="

# Step 1: Copy Ansible files and scripts to VM
echo "[Step 1/4] Copying Ansible files and scripts to VM..."
cd "$INFRA_DIR"
make make_rsync
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files to VM. Exiting."
    exit 1
fi
echo "✓ Ansible files and scripts copied successfully to VM."

# Step 2: Run Ansible installation on VM
echo "[Step 2/4] Installing Ansible on VM..."
"$INFRA_DIR/scripts/ssh.sh" "cd ~/ansible/scripts && chmod +x 00-install-ansible.sh && ./00-install-ansible.sh"
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Ansible on VM. Exiting."
    exit 1
fi
echo "✓ Ansible installed successfully on VM."

# Step 3: Install Ansible dependencies on VM
echo "[Step 3/4] Installing Ansible dependencies on VM..."
"$INFRA_DIR/scripts/ssh.sh" "cd ~/ansible/scripts && chmod +x 01-dependencies.sh && ./01-dependencies.sh"
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Ansible dependencies on VM. Exiting."
    exit 1
fi
echo "✓ Ansible dependencies installed successfully on VM."

# Step 4: Run Ansible playbook on VM
echo "[Step 4/4] Running Ansible playbook on VM..."
"$INFRA_DIR/scripts/ssh.sh" "cd ~/ansible && ansible-playbook main.yml"
if [ $? -ne 0 ]; then
    echo "Error: Failed to run Ansible playbook on VM. Exiting."
    exit 1
fi
echo "✓ Ansible playbook executed successfully on VM."

echo "=========================================================="
echo "  Ansible Provisioning Completed Successfully"
echo "=========================================================="
