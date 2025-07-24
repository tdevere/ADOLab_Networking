// variables.tf

variable "vmss_rg_name" {
  type        = string
  description = "Name of the VMSS resource group"
}

variable "kv_rg_name" {
  type        = string
  description = "Name of the Key Vault resource group"
}

variable "lab_vnet_rg_name" {
  type        = string
  description = "Name of the resource group for the lab VNet"
}

variable "lab_location" {
  type        = string
  description = "Azure region for all resources"
}

variable "lab_vnet_name" {
  type        = string
  description = "Name of the lab Virtual Network"
}

variable "lab_vnet_address_space" {
  type        = list(string)
  description = "Address space CIDRs for the lab VNet"
}

variable "vmss_subnet_name" {
  type        = string
  description = "Name of the subnet for the VM Scale Set"
}

variable "vmss_subnet_prefix" {
  type        = list(string)
  description = "Address prefix CIDRs for the VMSS subnet"
}

variable "kv_pe_subnet_name" {
  type        = string
  description = "Name of the subnet for the Key Vault private endpoint"
}

variable "kv_pe_subnet_prefix" {
  type        = list(string)
  description = "Address prefix CIDRs for the Key Vault PE subnet"
}

variable "vmss_name" {
  type        = string
  description = "Name of the VM Scale Set"
}

variable "vmss_sku" {
  type        = string
  description = "VM size SKU for the VM Scale Set"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM instances"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VM instances"
  sensitive   = true
}

variable "kv_name" {
  type        = string
  description = "Name of the Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD Tenant ID for Key Vault access"
}

variable "admin_ssh_key" {
  type        = string
  description = "SSH public key for VMSS instances"
}

variable "lab_rg_name" {
  type        = string
  description = "Name of the shared resource group for the lab"
}
