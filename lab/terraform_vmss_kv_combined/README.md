# Combined Azure VMSS + Key Vault Lab with Private Endpoint

This lab demonstrates how to deploy a secure Azure environment using Terraform, combining a Virtual Machine Scale Set (VMSS) and an Azure Key Vault with a private endpoint. The VMSS is configured to access the Key Vault securely via the private endpoint, and the NSG is set to allow only necessary traffic.

---

## Features
- Resource Group
- Virtual Network & two subnets (VMSS, Private Endpoint)
- Network Security Group (NSG) for VMSS
- Linux VMSS (single instance, system-assigned managed identity)
- Azure Key Vault with private endpoint
- NSG rule allowing VMSS subnet access to Key Vault private endpoint

---

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.4.0
- Azure CLI installed and authenticated (`az login`)
- Sufficient permissions to create resources in your Azure subscription

---

## Setup
1. **Clone or copy this directory**
2. **Copy and edit `terraform.tfvars.example` to `terraform.tfvars`**
   - Set your resource names, subnet prefixes, admin credentials, and tenant ID

---

## Usage

### 1. Initialize Terraform
```powershell
terraform init
```

### 2. Preview the deployment (Plan)
```powershell
terraform plan -out=tfplan
```

### 3. Deploy resources (Apply)
```powershell
terraform apply "tfplan"
```
Confirm the action when prompted.

### 4. Destroy resources
```powershell
terraform destroy -auto-approve
```
Confirm the action when prompted. This will remove all resources created by this lab.

---

## Architecture Overview
- **VMSS**: Deployed in its own subnet, with a system-assigned managed identity for secure access.
- **Key Vault**: Deployed with network ACLs to only allow access from the private endpoint subnet.
- **Private Endpoint**: Connects the Key Vault to the VNet, providing a private IP for secure access.
- **NSG**: Configured to allow outbound traffic from VMSS subnet to the Key Vault private endpoint IP on port 443.

---

## How to Test Key Vault Access from VMSS
1. SSH into the VMSS instance.
2. Use Azure CLI with the managed identity to access Key Vault secrets:
   ```bash
   az login --identity
   az keyvault secret list --vault-name <kv_name>
   ```
   You should be able to list secrets if the managed identity has access.

---

## Customization
- Change VMSS image, size, or admin credentials in `variables.tf` and `terraform.tfvars`
- Adjust subnet sizes and address spaces as needed
- Add custom scripts or extensions to configure VMSS instances

---

## Troubleshooting
- Ensure your Azure subscription has sufficient quota for VMSS, Key Vault, and Private Endpoint resources
- Check NSG rules if VMSS cannot access the Key Vault
- Review Terraform and Azure CLI output for errors
- Confirm the managed identity is granted access to Key Vault

---

## References
- [Terraform Azure Provider: Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
- [Terraform Azure Provider: VMSS](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set)
- [Azure Private Endpoint Documentation](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
