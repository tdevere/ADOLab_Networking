###############################################################################
# Minimal Azure DevOps VMSS Example
###############################################################################

# Resource Group
resource "azurerm_resource_group" "vmss_rg" {
  name     = var.vmss_rg_name
  location = var.vmss_location
}

# Virtual Network
resource "azurerm_virtual_network" "vmss_vnet" {
  name                = var.vmss_vnet_name
  address_space       = var.vmss_vnet_address_space
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name
}

# Subnet
resource "azurerm_subnet" "vmss_subnet" {
  name                 = var.vmss_subnet_name
  resource_group_name  = azurerm_resource_group.vmss_rg.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = [var.vmss_subnet_prefix]
}

# Network Security Group
resource "azurerm_network_security_group" "vmss_nsg" {
  name                = "${var.vmss_rg_name}-nsg"
  location            = azurerm_resource_group.vmss_rg.location
  resource_group_name = azurerm_resource_group.vmss_rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG Association
resource "azurerm_subnet_network_security_group_association" "vmss_assoc" {
  subnet_id                 = azurerm_subnet.vmss_subnet.id
  network_security_group_id = azurerm_network_security_group.vmss_nsg.id
}

# VMSS
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = azurerm_resource_group.vmss_rg.name
  location            = azurerm_resource_group.vmss_rg.location
  sku                 = var.vmss_sku
  instances           = 1
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  single_placement_group = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ipconfig"
      subnet_id = azurerm_subnet.vmss_subnet.id
    }
  }
}
