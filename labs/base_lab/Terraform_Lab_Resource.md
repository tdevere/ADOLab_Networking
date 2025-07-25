**Terraform Lab Resource Document (Combined Agent + Connectivity Labs)**

---

## 1. Overview

This lab demonstrates how to provision and manage two Azure environments using Terraform:

* **Agent Lab**: a self-hosted DevOps agent VM in its own network.
* **Connectivity Lab**: a Key Vault secured by private endpoints and a Private DNS zone with an intentional misconfiguration to simulate DNS failures and firewall blocks.

You will learn to organize a multi-module Terraform project, define resources for both scenarios, and drive deployments with inputs, outputs, and Terraform CLI workflows.

---

## 2. Lab Objectives

By the end of this lab, you will be able to:

* Structure a single Terraform project for two logical labs.
* Configure the AzureRM provider and pin versions.
* Define Azure resources for each lab:

  * **Agent Lab**: Resource Group, VNet, Subnet, NSG, Public IP, NIC, Linux VM.
  * **Connectivity Lab**: Resource Group, VNet, two Subnets, NSG, Key Vault, Private Endpoint, Private DNS Zone, correct & misconfigured A-records.
* Use input variables and override them via `.tfvars` files.
* Initialize, plan, apply, review, and destroy the combined infrastructure.

---

## 3. Prerequisites

* Azure subscription with **Contributor** role
* Azure CLI (latest) or PowerShell 7+ with **Az** modules
* Terraform CLI **≥ 1.4.0**
* SSH key pair for Linux VM (`ssh-keygen`)
* Git for cloning the repository

---

## 4. Repository & File Structure

```plaintext
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── terraform.tfvars.example
```

### 4.1 Resource Inventory

| Lab Component        | Resource Type                | Name / Variable                    | Purpose                                                  |
| -------------------- | ---------------------------- | ---------------------------------- | -------------------------------------------------------- |
| **Agent Lab**        | Resource Group               | `agent_rg_name`                    | RG for agent VNet, VM, NSG                               |
|                      | Virtual Network              | `agent_vnet_name`                  | VNet hosting the build-agent network                     |
|                      | Subnet                       | `agent_subnet_name`                | Subnet for agent VM NIC                                  |
|                      | Network Security Group       | `${agent_rg_name}-nsg`             | Allows SSH inbound; denies other traffic                 |
|                      | Public IP                    | `public_ip_name`                   | Public IP for agent VM                                   |
|                      | Network Interface            | `nic_name`                         | Attaches VM to subnet & public IP                        |
|                      | Linux Virtual Machine        | `vm_name`                          | Ubuntu VM acting as self-hosted DevOps agent             |
| **Connectivity Lab** | Resource Group               | `connect_rg_name`                  | RG for Key Vault, DNS, firewall lab                      |
|                      | Virtual Network              | `connect_vnet_name`                | VNet for connectivity testing                            |
|                      | Agents Subnet                | `connect_agents_subnet_name`       | Simulates pipeline network                               |
|                      | Private Endpoint Subnet      | `connect_pe_subnet_name`           | Hosts Key Vault private endpoint                         |
|                      | Network Security Group       | `${connect_rg_name}-nsg`           | Denies all inbound (firewall simulation)                 |
|                      | Key Vault                    | `key_vault_name`                   | Secured to private endpoint only                         |
|                      | Private Endpoint             | `${key_vault_name}-pe`             | Connects Key Vault into the VNet                         |
|                      | Private DNS Zone             | `vault.azure.net`                  | Resolves Key Vault FQDN internally                       |
|                      | DNS A record (correct)       | `<key_vault_name>.vault.azure.net` | Points to actual private endpoint IP                     |
|                      | DNS A record (misconfigured) | `<key_vault_name>-wrong`           | Points to `wrong_kv_ip` to simulate DNS misconfiguration |

---

## 5. Terraform Configuration Breakdown

### 5.1 `versions.tf`

```hcl
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### 5.2 `variables.tf`

```hcl
# Agent Lab variables
variable "agent_rg_name"               { type = string }
variable "agent_location"              { type = string }
variable "agent_vnet_name"             { type = string }
variable "agent_vnet_address_space"    { type = list(string) }
variable "agent_subnet_name"           { type = string }
variable "agent_subnet_prefix"         { type = string }
variable "public_ip_name"              { type = string }
variable "nic_name"                    { type = string }
variable "vm_name"                     { type = string }
variable "vm_size"                     { type = string }
variable "admin_username"              { type = string }
variable "admin_ssh_key"               { type = string }

# Connectivity Lab variables
variable "connect_rg_name"             { type = string }
variable "connect_location"            { type = string }
variable "connect_vnet_name"           { type = string }
variable "connect_vnet_address_space"  { type = list(string) }
variable "connect_agents_subnet_name"  { type = string }
variable "connect_agents_subnet_prefix"{ type = string }
variable "connect_pe_subnet_name"      { type = string }
variable "connect_pe_subnet_prefix"    { type = string }
variable "key_vault_name"              { type = string }
variable "wrong_kv_ip"                 { type = string }
```

### 5.3 `main.tf`

* **Agent Lab**:

  * `azurerm_resource_group.agent_rg`
  * `azurerm_virtual_network.agent_vnet`
  * `azurerm_subnet.agent_subnet`
  * `azurerm_network_security_group.agent_nsg`
  * `azurerm_subnet_network_security_group_association.agent_assoc`
  * `azurerm_public_ip.vm_public_ip`
  * `azurerm_network_interface.vm_nic`
  * `azurerm_linux_virtual_machine.agent_vm`

* **Connectivity Lab**:

  * `data.azurerm_client_config.current`
  * `azurerm_resource_group.connect_rg`
  * `azurerm_virtual_network.connect_vnet`
  * `azurerm_subnet.connect_agents_subnet`
  * `azurerm_subnet.connect_pe_subnet`
  * `azurerm_network_security_group.connect_nsg`
  * `azurerm_subnet_network_security_group_association.connect_agents_assoc`
  * `azurerm_key_vault.kv`
  * `azurerm_private_endpoint.kv_pe`
  * `azurerm_private_dns_zone.kv_zone`
  * `azurerm_private_dns_zone_virtual_network_link.kv_link`
  * `azurerm_private_dns_a_record.kv_a_correct`
  * `azurerm_private_dns_a_record.kv_a_misconfig`

### 5.4 `outputs.tf`

```hcl
# Agent Lab outputs
output "agent_resource_group" {
  description = "Agent lab Resource Group name"
  value       = azurerm_resource_group.agent_rg.name
}

output "agent_vm_public_ip" {
  description = "Public IP of the agent VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

# Connectivity Lab outputs
output "connectivity_resource_group" {
  description = "Connectivity lab Resource Group name"
  value       = azurerm_resource_group.connect_rg.name
}

output "key_vault_private_ip" {
  description = "Private IP of Key Vault endpoint"
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS zone"
  value       = azurerm_private_dns_zone.kv_zone.name
}

output "dns_records" {
  description = "Correct and misconfigured A-record IPs"
  value = [
    azurerm_private_dns_a_record.kv_a_correct.records[0],
    azurerm_private_dns_a_record.kv_a_misconfig.records[0],
  ]
}
```

### 5.5 `terraform.tfvars.example`

```hcl
# === Agent Lab ===
agent_rg_name               = "tf-agent-lab-rg"
agent_location              = "westus2"
agent_vnet_name             = "agent-vnet"
agent_vnet_address_space    = ["10.0.0.0/16"]
agent_subnet_name           = "agent-subnet"
agent_subnet_prefix         = "10.0.1.0/24"
public_ip_name              = "agent-vm-pip"
nic_name                    = "agent-vm-nic"
vm_name                     = "agent-vm"
vm_size                     = "Standard_B1ms"
admin_username              = "azureuser"
admin_ssh_key               = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."

# === Connectivity Lab ===
connect_rg_name             = "tf-connect-lab-rg"
connect_location            = "westus2"
connect_vnet_name           = "connect-vnet"
connect_vnet_address_space  = ["10.1.0.0/16"]
connect_agents_subnet_name  = "connect-agents-subnet"
connect_agents_subnet_prefix= "10.1.1.0/24"
connect_pe_subnet_name      = "connect-pe-subnet"
connect_pe_subnet_prefix    = "10.1.2.0/24"
key_vault_name              = "lab-kv-1234"
wrong_kv_ip                 = "10.1.2.50"
```

---

## 6. Lab Execution Steps

1. **Clone** the repository
2. **Copy** and **customize** `terraform.tfvars.example` → `terraform.tfvars`
3. Run `terraform init`
4. Run `terraform plan -out=tfplan`
5. Run `terraform apply tfplan`
6. Review the **outputs**, test SSH to VM, DNS lookups, and Key Vault connectivity
7. Clean up with `terraform destroy -auto-approve`

---

## 7. Troubleshooting & Tips

* Unlock state with `terraform force-unlock`
* Pin provider versions in `versions.tf`
* Authenticate: `az login` or `Connect-AzAccount`
* Use `terraform taint` to force resource recreation

---

## 8. Additional Resources

* [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
* [Terraform CLI Commands](https://www.terraform.io/docs/cli)
* [Azure Virtual Network Docs](https://docs.microsoft.com/azure/virtual-network/)

---

*End of updated Terraform Lab Resource Document*
