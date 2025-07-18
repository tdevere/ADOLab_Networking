###############################################################################
# Minimal Key Vault Example
###############################################################################

# Resource Group
resource "azurerm_resource_group" "kv_rg" {
  name     = var.kv_rg_name
  location = var.kv_location
}

# Network Security Group
resource "azurerm_network_security_group" "kv_nsg" {
  name                = "${var.kv_rg_name}-nsg"
  location            = azurerm_resource_group.kv_rg.location
  resource_group_name = azurerm_resource_group.kv_rg.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.kv_rg.location
  resource_group_name         = azurerm_resource_group.kv_rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days   = 7
  purge_protection_enabled     = false
}
