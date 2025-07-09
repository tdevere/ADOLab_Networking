###############################################################################
# Agent Lab
###############################################################################

# Resource Group
resource "azurerm_resource_group" "agent_rg" {
  name     = var.agent_rg_name
  location = var.agent_location
}

# VNet & Subnet
resource "azurerm_virtual_network" "agent_vnet" {
  name                = var.agent_vnet_name
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name
  address_space       = var.agent_vnet_address_space
}

resource "azurerm_subnet" "agent_subnet" {
  name                 = var.agent_subnet_name
  resource_group_name  = azurerm_resource_group.agent_rg.name
  virtual_network_name = azurerm_virtual_network.agent_vnet.name
  address_prefixes     = [var.agent_subnet_prefix]
}

# NSG & Association
resource "azurerm_network_security_group" "agent_nsg" {
  name                = "${var.agent_rg_name}-nsg"
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name

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

resource "azurerm_subnet_network_security_group_association" "agent_assoc" {
  subnet_id                 = azurerm_subnet.agent_subnet.id
  network_security_group_id = azurerm_network_security_group.agent_nsg.id
}

# Public IP, NIC, VM
resource "azurerm_public_ip" "vm_public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.agent_rg.location
  resource_group_name = azurerm_resource_group.agent_rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.agent_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "agent_vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.agent_rg.location
  resource_group_name   = azurerm_resource_group.agent_rg.name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size
  admin_username        = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

###############################################################################
# Connectivity Lab
###############################################################################

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "connect_rg" {
  name     = var.connect_rg_name
  location = var.connect_location
}

# VNet & Subnets
resource "azurerm_virtual_network" "connect_vnet" {
  name                = var.connect_vnet_name
  location            = azurerm_resource_group.connect_rg.location
  resource_group_name = azurerm_resource_group.connect_rg.name
  address_space       = var.connect_vnet_address_space
}

resource "azurerm_subnet" "connect_agents_subnet" {
  name                 = var.connect_agents_subnet_name
  resource_group_name  = azurerm_resource_group.connect_rg.name
  virtual_network_name = azurerm_virtual_network.connect_vnet.name
  address_prefixes     = [var.connect_agents_subnet_prefix]
}

resource "azurerm_subnet" "connect_pe_subnet" {
  name                 = var.connect_pe_subnet_name
  resource_group_name  = azurerm_resource_group.connect_rg.name
  virtual_network_name = azurerm_virtual_network.connect_vnet.name
  address_prefixes     = [var.connect_pe_subnet_prefix]
  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}

# NSG & Association
resource "azurerm_network_security_group" "connect_nsg" {
  name                = "${var.connect_rg_name}-nsg"
  location            = azurerm_resource_group.connect_rg.location
  resource_group_name = azurerm_resource_group.connect_rg.name

  security_rule {
    name                       = "DenyAll"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "connect_agents_assoc" {
  subnet_id                 = azurerm_subnet.connect_agents_subnet.id
  network_security_group_id = azurerm_network_security_group.connect_nsg.id
}

# Key Vault with Private Endpoint
resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.connect_rg.location
  resource_group_name         = azurerm_resource_group.connect_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled    = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.connect_pe_subnet.id]
  }
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${var.key_vault_name}-pe"
  location            = azurerm_resource_group.connect_rg.location
  resource_group_name = azurerm_resource_group.connect_rg.name
  subnet_id           = azurerm_subnet.connect_pe_subnet.id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

# Private DNS Zone & Records
resource "azurerm_private_dns_zone" "kv_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.connect_rg.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "kv-zone-link"
  resource_group_name   = azurerm_resource_group.connect_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_zone.name
  virtual_network_id    = azurerm_virtual_network.connect_vnet.id
}

resource "azurerm_private_dns_a_record" "kv_a_correct" {
  name                = azurerm_key_vault.kv.name
  zone_name           = azurerm_private_dns_zone.kv_zone.name
  resource_group_name = azurerm_resource_group.connect_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "kv_a_misconfig" {
  name                = "${azurerm_key_vault.kv.name}-wrong"
  zone_name           = azurerm_private_dns_zone.kv_zone.name
  resource_group_name = azurerm_resource_group.connect_rg.name
  ttl                 = 300
  records             = [var.wrong_kv_ip]
}
