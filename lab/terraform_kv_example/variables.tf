variable "kv_rg_name" {
  description = "Resource group name for Key Vault example"
  type        = string
}

variable "kv_location" {
  description = "Azure region for Key Vault example"
  type        = string
  default     = "westus2"
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}
