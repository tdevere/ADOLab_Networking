variable "location" {
  description = "Azure region for backend resources"
  default     = "eastus"
}

variable "lab_scenario" {
  description = "Lab scenario name (controls resource toggling)"
  type        = string
  default     = "base"
}
##########################
# Agent Lab Variables
##########################
variable "agent_rg_name" {
  description = "Resource group for build agent lab"
  type        = string
}

variable "agent_location" {
  description = "Azure region for agent lab"
  type        = string
  default     = "westus2"
}

variable "agent_vnet_name" {
  description = "VNet name for agent lab"
  type        = string
}

variable "agent_vnet_address_space" {
  description = "Address space for agent lab VNet"
  type        = list(string)
}

variable "agent_subnet_name" {
  description = "Subnet name for agent lab"
  type        = string
}

variable "agent_subnet_prefix" {
  description = "Subnet prefix for agent lab"
  type        = string
}

variable "public_ip_name" {
  description = "Public IP for the VM"
  type        = string
}

variable "nic_name" {
  description = "Network interface name for the VM"
  type        = string
}

variable "vm_name" {
  description = "Linux VM name (for agent)"
  type        = string
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type = string
  sensitive = true
}

variable "admin_ssh_key" {
  description = "Public SSH key for VM login"
  type        = string
}

##########################
# Connectivity Lab Variables
##########################
variable "connect_rg_name" {
  description = "Resource group for connectivity lab"
  type        = string
}

variable "connect_location" {
  description = "Azure region for connectivity lab"
  type        = string
  default     = "westus2"
}

variable "connect_vnet_name" {
  description = "VNet name for connectivity lab"
  type        = string
}

variable "connect_vnet_address_space" {
  description = "Address space for connectivity lab VNet"
  type        = list(string)
}

variable "connect_agents_subnet_name" {
  description = "Agents subnet name for connectivity lab"
  type        = string
}

variable "connect_agents_subnet_prefix" {
  description = "Prefix for agents subnet"
  type        = string
}

variable "connect_pe_subnet_name" {
  description = "Private endpoint subnet name"
  type        = string
}

variable "connect_pe_subnet_prefix" {
  description = "Prefix for private endpoint subnet"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "wrong_kv_ip" {
  description = "Misconfigured IP to simulate DNS failure"
  type        = string
}
