variable "vmss_rg_name" {
  description = "Resource group name for VMSS lab"
  type        = string
}

variable "vmss_location" {
  description = "Azure region for VMSS lab"
  type        = string
  default     = "westus2"
}

variable "vmss_vnet_name" {
  description = "VNet name for VMSS lab"
  type        = string
}

variable "vmss_vnet_address_space" {
  description = "Address space for VMSS VNet"
  type        = list(string)
}

variable "vmss_subnet_name" {
  description = "Subnet name for VMSS lab"
  type        = string
}

variable "vmss_subnet_prefix" {
  description = "Subnet prefix for VMSS lab"
  type        = string
}

variable "vmss_name" {
  description = "VMSS name"
  type        = string
}

variable "vmss_sku" {
  description = "VMSS SKU"
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "Admin username for VMSS"
  type        = string
}

variable "admin_password" {
  description = "Admin password for VMSS"
  type        = string
  sensitive   = true
}
