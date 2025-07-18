output "vmss_resource_group" {
  description = "Name of the VMSS resource group"
  value       = azurerm_resource_group.vmss_rg.name
}

output "vmss_id" {
  description = "ID of the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vmss_nsg_id" {
  description = "ID of the NSG for VMSS"
  value       = azurerm_network_security_group.vmss_nsg.id
}
