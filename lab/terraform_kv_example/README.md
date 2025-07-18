# Minimal Azure Key Vault Terraform Lab

This example demonstrates how to deploy a minimal Azure environment using Terraform, including:
- Resource Group
- Network Security Group (NSG)
- Azure Key Vault

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.4.0
- Azure CLI (for authentication)
- Sufficient permissions to create resources in your Azure subscription

## Setup
1. **Clone or copy this directory**
2. **Update `terraform.tfvars`** with your desired values (resource names, region, tenant ID, etc.)
   - You can pre-populate values for `kv_rg_name` and `tenant_id` in `terraform.tfvars`:
     ```hcl
     kv_rg_name = "your-default-rg-name"
     tenant_id  = "your-tenant-id"
     ```
   - Alternatively, set defaults in `variables.tf`:
     ```hcl
     variable "kv_rg_name" {
       default = "your-default-rg-name"
       # ...other settings...
     }
     variable "tenant_id" {
       default = "your-tenant-id"
       # ...other settings...
     }
     ```
   - If these are set, you do not need to pass them as CLI arguments.

## Authentication
Login to Azure using the CLI:
```powershell
az login
```

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

## Outputs
After deployment, Terraform will display:
- Resource group name
- NSG ID
- Key Vault ID

## Notes
- The Key Vault requires a valid Azure tenant ID. You can find it with:
  ```powershell
  az account show --query tenantId -o tsv
  ```
- All resources are created in the region specified by `kv_location` (default: westus2).

---
For more details, see the official [Terraform Azure Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).
