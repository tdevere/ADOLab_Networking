output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.kv_rg.name
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.kv_nsg.id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}
