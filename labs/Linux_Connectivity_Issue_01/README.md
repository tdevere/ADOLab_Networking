# Lab: Linux Connectivity Issue 01

> **🔄 Quick Lab Reset for Instructors**: After students complete the lab, run: `az network nic ip-config update --resource-group rg-agent-connectivity-lab --nic-name nic-linux-agent --name ipconfig1 --remove publicIpAddress` to restore the broken state for the next student.

## Scenario
You are a DevOps support engineer. The Linux build agent is unreachable due to a missing public IP. Your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## How to Run This Scenario
1. **Navigate to the base lab folder:**
   ```powershell
   cd ../base_lab
   ```
2. **Initialize Terraform:**
   ```powershell
   terraform init
   ```
3. **Plan and apply with scenario variables:**
   ```powershell
   $sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
   terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
   terraform apply tfplan
   ```

This will provision the environment with the public IP for the Linux agent disabled, simulating the connectivity issue.

---

## Troubleshooting Tasks
1. Attempt to SSH to the agent using the public IP (should fail).
2. Check the VM's networking configuration in the Azure Portal.
3. Use Azure CLI or Portal to verify if the public IP is attached and enabled.
4. Re-enable or re-attach the public IP using Azure Portal or CLI.
5. Confirm the agent is reachable via SSH and appears online in the DevOps agent pool.
6. Document your troubleshooting steps and resolution.

---

## Notes
- Do not use Terraform to fix the issue. The lab simulates a real-world operational scenario.
- If you need to roll back, contact your instructor or use provided rollback instructions.

# Lab: Linux Connectivity Issue 01
## Scenario
You are a DevOps support engineer. A build pipeline is failing because the Linux build agent is unreachable. The environment was provisioned for you—your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## Lab Setup
Follow these steps to set up your lab environment:

### **Step 1: Generate SSH Key (if you don't have one)**
```powershell
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\terraform_lab_key -N '""'
```

### **Step 2: Navigate to the base lab folder**
```powershell
# If you haven't cloned the repository yet:
git clone https://github.com/tdevere/ADOLab_Networking.git

# Navigate to base lab folder
cd ADOLab_Networking/labs/base_lab
```

### **Step 3: Initialize Terraform**
```powershell
terraform init
```

### **Step 4: Deploy the lab infrastructure**
```powershell
# Load your SSH key
$sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub

# Plan the deployment (this will create the connectivity issue)
terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -var="admin_password=YourSecurePassword123!" -out=tfplan

# Apply the plan to create the infrastructure
terraform apply tfplan
```

### **Step 5: Verify the connectivity issue is created**
```powershell
# This should return empty/null - confirming no public IP attached
terraform output agent_vm_public_ip

# Check VM details to confirm the setup
az vm show -g rg-agent-connectivity-lab -n vm-linux-agent --query "networkProfile.networkInterfaces" -o json
```

**What happens:** The deployment will create a Linux VM **without a public IP attached**, simulating the exact connectivity issue you need to troubleshoot and resolve using Azure tools.

### **⏱️ Estimated Timing:**
- **Lab Setup**: 5-10 minutes (Terraform deployment)
- **Troubleshooting**: 15-30 minutes (depending on experience)
- **Lab Reset**: 1-2 minutes (simple CLI command)

---

## Symptoms
- Azure DevOps pipeline fails with error:
  > Agent unreachable: SSH connection timed out
- You cannot SSH to the Linux agent using its public IP.
- The agent does not appear online in the Azure DevOps agent pool.

---

## Your Tasks
1. **Diagnose the Issue**
   - Attempt to SSH to the agent using the public IP (provided in the outputs or portal).
   - Check the VM's networking configuration in the Azure Portal.
   - Use Azure CLI or Portal to verify if the public IP is attached and enabled.

2. **Resolve the Issue**
   - Re-enable or re-attach the public IP to the Linux agent VM using the Azure Portal or CLI.
   - Confirm that the agent is reachable via SSH and appears online in the DevOps agent pool.

3. **Document Your Steps**
   - List the troubleshooting steps you performed.
   - Include screenshots or CLI output showing the resolution.

---

## Detailed Troubleshooting Steps

### 1. Attempt SSH Connection
```powershell
# First, try to get the public IP from Terraform outputs (this will fail in this scenario)
terraform output agent_vm_public_ip

# Since there's no public IP attached, you'll need to find the VM's details using Azure CLI
az vm show -g rg-agent-connectivity-lab -n vm-linux-agent --query "publicIps" -o tsv

# Or check all public IPs in the resource group
az network public-ip list -g rg-agent-connectivity-lab --query "[].{Name:name, IPAddress:ipAddress, Associated:ipConfiguration.id}" --output table
```
If the commands show no public IP or empty results, this confirms the connectivity issue.

### 2. Check VM Networking in Azure Portal
- Go to the Azure Portal > Virtual Machines > [Your Linux Agent VM].
- Under **Networking**, verify if a public IP address is listed and attached to the network interface.
- If no public IP is present, this is likely the cause of the connectivity issue.

### 3. Use Azure CLI to Check Public IP
```bash
# Check the specific VM's network configuration
az vm show -g rg-agent-connectivity-lab -n vm-linux-agent --query "networkProfile.networkInterfaces" -o json

# List all public IPs in the lab resource group
az network public-ip list -g rg-agent-connectivity-lab -o table

# Check the specific Linux agent's network interface
az network nic show -g rg-agent-connectivity-lab -n nic-linux-agent --query "ipConfigurations[0].publicIpAddress" -o tsv
```

### 4. Re-enable or Attach Public IP
**Azure Portal:**
- Go to the VM's **Networking** blade.
- Click on the network interface.
- Under **IP configurations**, add or enable a public IP address.
- Save changes.

**Azure CLI:**
Attach the existing public IP to the VM's NIC:
```bash
# Method 1: Attach the existing public IP to the Linux VM's network interface
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --public-ip-address pip-linux-agent

# Method 2: If you need to create a new public IP first
az network public-ip create \
  --resource-group rg-agent-connectivity-lab \
  --name pip-linux-agent-new \
  --allocation-method Dynamic

# Then attach the new public IP
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --public-ip-address pip-linux-agent-new
```

### 5. Verify SSH and Agent Pool Status
After attaching the public IP, verify the fix:

```powershell
# Get the newly assigned public IP address
$publicIP = az network public-ip show -g rg-agent-connectivity-lab -n pip-linux-agent --query "ipAddress" -o tsv
Write-Host "Linux VM Public IP: $publicIP"

# Test SSH connectivity (replace with your actual SSH key path)
ssh -i $env:USERPROFILE\.ssh\terraform_lab_key azureuser@$publicIP

# Alternative: Test basic connectivity
Test-NetConnection -ComputerName $publicIP -Port 22
```

```bash
# For bash/Linux users
PUBLIC_IP=$(az network public-ip show -g rg-agent-connectivity-lab -n pip-linux-agent --query "ipAddress" -o tsv)
echo "Linux VM Public IP: $PUBLIC_IP"

# Test SSH connection
ssh -i ~/.ssh/terraform_lab_key azureuser@$PUBLIC_IP
```

- Check the agent status in Azure DevOps agent pool (if applicable).

### 6. Document Your Resolution
- List the steps you performed.
- Include screenshots or CLI output showing the VM's networking before and after the fix.
- Note the agent's status in Azure DevOps after resolution.

---

## Lab Resources Reference

After deployment, your lab will contain these key resources:

### **Agent Lab Resources (rg-agent-connectivity-lab)**
- **Linux VM**: `vm-linux-agent` (no public IP attached - this is the issue!)
- **Windows VM**: `vm-linux-agent-win` (has connectivity for comparison)
- **Linux Public IP**: `pip-linux-agent` (exists but unattached)
- **Linux NIC**: `nic-linux-agent` (attached to VM but no public IP)
- **VNet**: `vnet-agent-connectivity` (10.1.0.0/16)
- **Subnet**: `subnet-agent` (10.1.1.0/24)

### **Expected Behavior**
- ✅ Windows VM: Reachable via RDP (for comparison)
- ❌ Linux VM: **Unreachable via SSH** (this is what you need to fix)
- 🔧 Public IP: Exists but not attached to Linux VM

### **Resolution Goal**
Attach `pip-linux-agent` to `nic-linux-agent` using Azure Portal or CLI.

---

## Notes
- **Do not use Terraform to fix the issue.** The lab is designed to simulate a real-world scenario where you must use Azure operational tools.
- If you need to roll back, contact your instructor or use the provided rollback instructions (if any).

---

## Troubleshooting Tips

### **Common Issues and Solutions:**

1. **"Permission denied (publickey)" when SSH'ing**
   - Ensure you're using the correct SSH key path
   - Check that the key file has proper permissions: `chmod 600 ~/.ssh/terraform_lab_key`

2. **Public IP shows as "Creating" or "Updating"**
   - Wait a few minutes for Azure to complete the assignment
   - Check status: `az network public-ip show -g rg-agent-connectivity-lab -n pip-linux-agent`

3. **Can't find the public IP in Azure Portal**
   - Navigate to: Portal → Resource Groups → rg-agent-connectivity-lab → pip-linux-agent

4. **SSH still fails after attaching public IP**
   - Verify the public IP is actually assigned: `az network public-ip list -g rg-agent-connectivity-lab -o table`
   - Check NSG rules allow SSH (port 22): `az network nsg rule list -g rg-agent-connectivity-lab --nsg-name rg-agent-connectivity-lab-nsg -o table`

### **Quick Verification Commands:**
```bash
# Verify the fix worked
az network nic show -g rg-agent-connectivity-lab -n nic-linux-agent --query "ipConfigurations[0].publicIpAddress.id" -o tsv

# Should return something like: /subscriptions/.../pip-linux-agent
```

---

## Example Error Message
```
##[error]The agent is not responding. Check network connectivity and firewall settings.
```

---

## Lab Cleanup and Restoration

After completing the lab exercise, you can restore the environment to its original broken state for others to use, or completely clean up the resources.

### **Option 1: Restore to Original Broken State (Recommended for Reuse)**

To reset the lab back to the connectivity issue scenario:

```powershell
# Method A: Remove the public IP from the Linux VM's NIC (simulates the original issue)
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --remove publicIpAddress

# Verify the issue is restored
az network nic show -g rg-agent-connectivity-lab -n nic-linux-agent --query "ipConfigurations[0].publicIpAddress" -o tsv
# Should return: null or empty
```

```bash
# Alternative: For bash/Linux users
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --remove publicIpAddress

echo "Lab restored to broken state - no public IP attached to Linux VM"
```

### **Option 2: Complete Lab Cleanup (Remove All Resources)**

To completely remove all lab resources:

```powershell
# Navigate back to the base lab directory
cd c:\Repos\ADOLab_Networking\labs\base_lab

# Destroy all resources created by Terraform
terraform destroy -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=dummy" -var="admin_password=TempPassword123!" -auto-approve

# Verify cleanup
az group list --query "[?contains(name, 'connectivity') || contains(name, 'agent')].name" -o table
```

### **Option 3: Reset via Terraform (Recommended)**

The cleanest way to reset the lab to its original broken state:

```powershell
# Load your SSH key
$sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub

# Re-apply the original scenario configuration
terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -var="admin_password=YourSecurePassword123!" -out=tfplan
terraform apply tfplan

# This will restore the lab to the exact original broken state
```

### **Option 4: Restore to Base Configuration (Normal Working State)**

To restore the lab to a completely clean, working base configuration where all VMs have proper connectivity:

```powershell
# Navigate to the base lab directory
cd c:\Repos\ADOLab_Networking\labs\base_lab

# Load your SSH key
$sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub

# Apply the base configuration (everything working normally)
terraform plan -var-file="base.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
terraform apply tfplan

# Verify the base configuration is working
terraform output
```

**Base Configuration Features:**
- ✅ Linux VM: **Has public IP attached** - fully reachable via SSH
- ✅ Windows VM: Has public IP and RDP connectivity
- ✅ All networking components properly configured
- ✅ No lab scenarios active - clean baseline state

This is useful when you want to:
- Start fresh with a working environment
- Prepare for a different lab scenario
- Validate that the infrastructure works normally
- Use as a baseline for other networking experiments

### **Verification Commands**

After cleanup/restoration, verify the state:

```powershell
# Check that Linux VM has no public IP (for restore option)
az network nic show -g rg-agent-connectivity-lab -n nic-linux-agent --query "ipConfigurations[0].publicIpAddress" -o tsv

# Check that resources exist but are in broken state
az vm list -g rg-agent-connectivity-lab --query "[].{Name:name, PowerState:powerState}" -o table

# Verify public IP exists but is unattached
az network public-ip list -g rg-agent-connectivity-lab --query "[].{Name:name, IPAddress:ipAddress, Associated:ipConfiguration.id}" -o table
```

### **Expected Results After Restoration:**
- ✅ `vm-linux-agent` exists but has no public IP
- ✅ `pip-linux-agent` exists but shows no IP address and no association
- ✅ Lab is ready for the next student to troubleshoot

### **Lab Management Summary:**

| Action | Command | Use Case |
|--------|---------|----------|
| **Reset to Broken State** | `az network nic ip-config update --resource-group rg-agent-connectivity-lab --nic-name nic-linux-agent --name ipconfig1 --remove publicIpAddress` | Prepare lab for next student |
| **Fix the Issue** | `az network nic ip-config update --resource-group rg-agent-connectivity-lab --nic-name nic-linux-agent --name ipconfig1 --public-ip-address pip-linux-agent` | Student solution |
| **Restore via Terraform** | `terraform apply` with `scenario.tfvars` | Reset to exact broken state |
| **Base Configuration** | `terraform apply` with `base.tfvars` | Clean working baseline |
| **Complete Cleanup** | `terraform destroy` | Remove all resources |

---

## Resources
- [Troubleshoot VM connectivity in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/troubleshooting/connectivity)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure DevOps Agent Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)