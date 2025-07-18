# Minimal Azure DevOps VMSS Lab

This lab demonstrates how to deploy a minimal Azure Virtual Machine Scale Set (VMSS) using Terraform, with a single Linux instance to control cost.

## Features
- Resource Group
- Virtual Network & Subnet
- Network Security Group (NSG) with SSH access
- NSG association to subnet
- Linux VMSS (single instance)

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.4.0
- Azure CLI installed
- Sufficient permissions to create resources in your Azure subscription

## Setup
1. **Clone or copy this directory**
2. **Copy and edit `terraform.tfvars.example` to `terraform.tfvars`**
   - Set your resource names, subnet, and admin credentials

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


# VMSS‑Backed Self‑Hosted Agents

This guide walks you through deploying and configuring a Virtual Machine Scale Set (VMSS) via Terraform and syncing it with an Azure DevOps Agent Pool. You’ll enable a system‑assigned managed identity on the VMSS, grant it permissions in Azure DevOps, and verify that your new agents register successfully.

---

## Prerequisites

* **Azure Subscription** with Contributor rights
* **Azure DevOps Organization** with Agent Pools permissions
  * Owner or Project Collection Administrator to configure pool security
* **Terraform CLI** installed locally
* **Azure CLI** installed and authenticated (`az login`)

---

## 1. Deploy the VMSS via Terraform

Your Terraform configuration should:

1. Create a **Resource Group**
2. Provision a **Virtual Network** and **Subnet**
3. Deploy a **VMSS** using a Linux agent image
4. **Enable System‑Assigned Managed Identity** on the VMSS

Example snippet in `main.tf`:

```hcl
resource "azurerm_linux_virtual_machine_scale_set" "agent_pool" {
  name                = "vmss-lab"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku                 = "Standard_DS2_v2"
  instances           = 1

  source_image_reference {
    publisher = "mcr.microsoft.com"
    offer     = "ubuntu-server"
    sku       = "20_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = azurerm_subnet.subnet.id
    }
  }

  # ... other settings (OS disk, upgrade policy, etc.)
}
```

Run:

```powershell
terraform init
terraform apply -auto-approve
```

---

## 2. Enable the VMSS System‑Assigned Identity

After deployment, confirm identity is enabled:

```powershell
az vmss identity show \
  --resource-group <rg-name> \
  --name vmss-lab \
  --query principalId -o tsv
```

* A non-empty GUID means the system‑assigned identity is active.

---

## 3. Create or Update the Azure DevOps Agent Pool

1. In Azure DevOps, go to **Organization settings → Agent pools**.
2. Click **+ Add pool** and name it `VMSSLAB` (or your chosen name).
3. Under **Pool settings**, set **Auto‑provision from Azure** to **Off** (we’ll use Terraform).
4. Save the new pool.

---

## 4. Grant the VMSS Identity Access to the Agent Pool

1. Still in Azure DevOps, select your **VMSSLAB** pool and go to **Security**.
2. Click **+ Add**.
3. In the identity picker, switch to **Azure Active Directory** mode.
4. Paste the **principalId** (GUID) you retrieved in section 2 and press **Enter**.
5. Assign **Read & manage** (or **Manage**) permissions and click **Save**.

> **Note:** If the identity isn’t yet visible, ensure your ADO organization is connected to the same Azure AD tenant.

---

## 5. Configure the VMSS Extension for Agent Registration

Use the Azure CLI or Terraform extension to install and configure the DevOps agent on each VMSS instance.

### CLI example

```powershell
az vmss extension set \
  --resource-group <rg-name> \
  --vmss-name vmss-lab \
  --name AzurePipelinesAgent \
  --publisher Microsoft.VisualStudio.Services \
  --protected-settings '{
      "Url": "https://dev.azure.com/<org>/",
      "Pool": "VMSSLAB",
      "AgentNamePrefix": "vmss-lab",
      "UseSystemAssignedIdentity": true
    }'
```

### Terraform example

```hcl
resource "azurerm_virtual_machine_scale_set_extension" "ado_agent" {
  name                 = "AzurePipelinesAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.agent_pool.id
  publisher            = "Microsoft.VisualStudio.Services"
  type                 = "TeamServicesAgentLinux"
  type_handler_version = "1.0"

  protected_settings = jsonencode({
    Url                    = "https://dev.azure.com/<org>/"
    Pool                   = "VMSSLAB"
    AgentNamePrefix        = "vmss-lab"
    UseSystemAssignedIdentity = true
  })
}
```

---

## 6. Verify Agent Registration

1. In Azure DevOps **Agent pools → VMSSLAB → Agents**, you should see new agents come online within a few minutes.
2. In the VMSS **Diagnostics** tab, confirm no scaling‑in events occur.
3. Optionally, SSH/RDP into a VMSS instance and inspect `/azp/agent/_diag` (Linux) or `C:\azp\agent\_diag` (Windows) for extension logs.

---

## 7. Troubleshooting Tips

* **Permission errors (`TF400813`)**: Re‑check that the identity’s GUID is in the pool’s security with **Read & manage**.
* **Network blocks**: Ensure outbound 443 to `dev.azure.com` isn’t blocked by NSGs/UDRs.
* **Extension failures**: Increase extension log level:

  ```powershell
  az vmss extension set \
    --resource-group <rg> \
    --vmss-name vmss-lab \
    --name AzurePipelinesAgent \
    --publisher Microsoft.VisualStudio.Services \
    --settings '{"logLevel":"Debug"}'
  ```

---
