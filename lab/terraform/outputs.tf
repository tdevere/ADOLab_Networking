##########################
# Agent Lab Outputs
##########################

output "agent_resource_group" {
  description = "Name of the agent-lab resource group"
  value       = azurerm_resource_group.agent_rg.name
}

output "agent_vnet_id" {
  description = "ID of the agent lab VNet"
  value       = azurerm_virtual_network.agent_vnet.id
}

output "agent_subnet_id" {
  description = "ID of the agent lab subnet"
  value       = azurerm_subnet.agent_subnet.id
}

output "agent_nsg_id" {
  description = "ID of the NSG for agent lab"
  value       = azurerm_network_security_group.agent_nsg.id
}

output "agent_vm_public_ip" {
  description = "Public IP address of the agent VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "windows_admin_password" {
  value     = azurerm_linux_virtual_machine.agent_vm.admin_password
  sensitive = true
}


##########################
# Connectivity Lab Outputs
##########################

output "connectivity_resource_group" {
  description = "Name of the connectivity-lab resource group"
  value       = azurerm_resource_group.connect_rg.name
}

output "connectivity_vnet_id" {
  description = "ID of the connectivity lab VNet"
  value       = azurerm_virtual_network.connect_vnet.id
}

output "connectivity_agents_subnet_id" {
  description = "ID of the agents subnet in connectivity lab"
  value       = azurerm_subnet.connect_agents_subnet.id
}

output "connectivity_nsg_id" {
  description = "ID of the NSG for connectivity lab"
  value       = azurerm_network_security_group.connect_nsg.id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_private_ip" {
  description = "Private IP of Key Vault private endpoint"
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}

output "private_dns_zone_name" {
  description = "Name of the Private DNS zone"
  value       = azurerm_private_dns_zone.kv_zone.name
}

output "dns_records" {
  description = "Correct and misconfigured A-record IPs"
  value = concat(
    tolist(azurerm_private_dns_a_record.kv_a_correct.records),
    tolist(azurerm_private_dns_a_record.kv_a_misconfig.records),
  )
}

