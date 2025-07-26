# Azure Networking Lab - Base Configuration

This directory contains the base Terraform configuration for Azure networking troubleshooting labs. The configuration can be deployed in different scenarios using various `.tfvars` files.

## Available Configurations

### 1. Base Configuration (Normal Operation)
**File:** `base.tfvars`  
**Purpose:** Clean, working baseline where all networking components function normally  
**Features:**
- ✅ Linux VM with public IP attached (reachable via SSH)
- ✅ Windows VM with public IP attached (reachable via RDP)
- ✅ All networking properly configured
- ✅ No intentional issues for troubleshooting

**Use Cases:**
- Starting fresh with a working environment
- Validating infrastructure works normally
- Baseline for other lab scenarios
- Preparation for different networking experiments

### 2. Linux Connectivity Issue Scenario
**File:** `../Linux_Connectivity_Issue_01/scenario.tfvars`  
**Purpose:** Simulates connectivity problems with Linux build agent  
**Features:**
- ❌ Linux VM without public IP (creates connectivity issue)
- ✅ Windows VM works normally (for comparison)
- 🔧 All infrastructure present but misconfigured for lab scenario

**Use Cases:**
- Student troubleshooting exercises
- Learning Azure networking diagnostics
- Practice with Azure CLI/Portal fixes

## Quick Start

### Deploy Base Configuration (Working State)
```powershell
# Navigate to base lab directory
cd c:\Repos\ADOLab_Networking\labs\base_lab

# Initialize Terraform (if not done already)
terraform init

# Load SSH key and deploy base configuration
$sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
terraform plan -var-file="base.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
terraform apply tfplan
```

### Deploy Linux Connectivity Issue Lab
```powershell
# Use the Linux connectivity issue scenario
terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
terraform apply tfplan
```

### Switch Between Configurations
You can easily switch between configurations by applying different `.tfvars` files:

```powershell
# Switch to base (working) configuration
terraform apply -var-file="base.tfvars" -var="admin_ssh_key=$sshkey" -auto-approve

# Switch to broken connectivity scenario
terraform apply -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -auto-approve
```

## Configuration Management

### Lab Scenario Variable
The key variable that controls lab behavior is `lab_scenario`:
- `lab_scenario = "base"` → Normal operation, all VMs have public IPs
- `lab_scenario = "Linux_Connectivity_Issue_01"` → Linux VM public IP detached

### Key Resources Created
- **Agent Lab Resource Group:** `rg-agent-connectivity-lab`
- **Linux VM:** `vm-linux-agent` (behavior depends on scenario)
- **Windows VM:** `vm-linux-agent-win` (always has connectivity)
- **Public IPs:** `pip-linux-agent` (existence/attachment varies by scenario)
- **VNet:** `vnet-agent-connectivity` (10.1.0.0/16)

### Cleanup Options
```powershell
# Complete removal of all resources
terraform destroy -var-file="base.tfvars" -var="admin_ssh_key=dummy" -var="admin_password=TempPassword123!" -auto-approve
```

## Files in This Directory

- `main.tf` - Core infrastructure definitions with conditional logic
- `variables.tf` - Variable declarations and defaults
- `outputs.tf` - Output values (IP addresses, resource IDs)
- `versions.tf` - Provider version constraints
- `base.tfvars` - Base configuration variables (normal operation)
- `terraform.tfvars.example` - Example configuration template
- `README.md` - This documentation file

## SSH Key Requirements

All deployments require an SSH key for Linux VM access:
```powershell
# Generate if needed
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\terraform_lab_key -N '""'

# Load for use
$sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
```

## Troubleshooting

If you encounter issues:
1. Ensure Terraform is initialized: `terraform init`
2. Validate configuration: `terraform validate`
3. Check Azure CLI authentication: `az account show`
4. Verify SSH key exists and is readable
5. Check for existing resource naming conflicts

For detailed lab instructions and troubleshooting scenarios, see the specific lab directories (e.g., `../Linux_Connectivity_Issue_01/README.md`).
