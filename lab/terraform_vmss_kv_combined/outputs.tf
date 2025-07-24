# Outputs for the lab


output "vmss_id" {
  description = "The ID of the Linux Virtual Machine Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "private_endpoint_ip" {
  description = "The private IP address of the Key Vault Private Endpoint."
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}
