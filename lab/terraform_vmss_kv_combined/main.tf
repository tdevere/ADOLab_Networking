###############################################################################
# main.tf
#
# Full lab: subnet for KV PE, NSG, Key Vault w/ PE, ASG, and Linux VMSS
###############################################################################


# -------------------------------------------------------------------
# Resource Group (shared)
# -------------------------------------------------------------------
resource "azurerm_resource_group" "lab_rg" {
  name     = var.lab_rg_name
  location = var.lab_location
}

# -------------------------------------------------------------------
# Virtual Network & Subnets (shared)
# -------------------------------------------------------------------
resource "azurerm_virtual_network" "lab_vnet" {
  name                = var.lab_vnet_name
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location
  address_space       = var.lab_vnet_address_space
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = var.vmss_subnet_name
  resource_group_name  = azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = var.vmss_subnet_prefix
}

resource "azurerm_subnet" "kv_pe_subnet" {
  name                 = var.kv_pe_subnet_name
  resource_group_name  = azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = var.kv_pe_subnet_prefix
  private_endpoint_network_policies = "Disabled"
  service_endpoints                 = ["Microsoft.KeyVault"]
}

# -------------------------------------------------------------------
# NSG on the Key Vault subnet (to lock it down to only the VMSS subnet)
# -------------------------------------------------------------------
resource "azurerm_network_security_group" "kv_nsg" {
  name                = "kv-nsg"
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location

  security_rule {
    name                               = "AllowFromVMSS"
    priority                           = 100
    direction                          = "Inbound"
    access                             = "Allow"
    protocol                           = "*"
    source_address_prefix              = var.vmss_subnet_prefix[0]
    destination_address_prefix         = var.kv_pe_subnet_prefix[0]
    source_port_range                  = "*"
    destination_port_range             = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "kv_assoc" {
  subnet_id                 = azurerm_subnet.kv_pe_subnet.id
  network_security_group_id = azurerm_network_security_group.kv_nsg.id
}

# -------------------------------------------------------------------
# Key Vault + Private Endpoint
# -------------------------------------------------------------------
resource "azurerm_key_vault" "kv" {
  name                       = var.kv_name
  resource_group_name        = azurerm_resource_group.lab_rg.name
  location                   = azurerm_resource_group.lab_rg.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.kv_pe_subnet.id]
  }
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${var.kv_name}-pe"
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location
  subnet_id           = azurerm_subnet.kv_pe_subnet.id

  private_service_connection {
    name                           = "${var.kv_name}-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

# -------------------------------------------------------------------
# Linux VMSS for Azure DevOps Pool
# -------------------------------------------------------------------
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = azurerm_resource_group.lab_rg.name
  location            = azurerm_resource_group.lab_rg.location
  sku                 = var.vmss_sku
  instances           = 1

  admin_username = var.admin_username
  admin_password = var.admin_password

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ipcfg"
      subnet_id = azurerm_subnet.vmss_subnet.id
      primary   = true
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  single_placement_group = true
}
