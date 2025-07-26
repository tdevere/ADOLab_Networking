# Linux Connectivity Issue Lab - Main Configuration
# This lab creates infrastructure with a connectivity issue (missing public IP)
# that must be resolved using Azure Portal or CLI (not Terraform)

module "base" {
  source = "../base_lab"
  
  # Lab scenario to trigger connectivity issue simulation
  lab_scenario                = "Linux_Connectivity_Issue_01"
  
  # Agent Lab Variables
  agent_rg_name               = var.agent_rg_name
  agent_location              = var.agent_location
  agent_vnet_name             = var.agent_vnet_name
  agent_vnet_address_space    = var.agent_vnet_address_space
  agent_subnet_name           = var.agent_subnet_name
  agent_subnet_prefix         = var.agent_subnet_prefix
  public_ip_name              = var.public_ip_name
  nic_name                    = var.nic_name
  vm_name                     = var.vm_name
  vm_size                     = var.vm_size
  admin_username              = var.admin_username
  admin_ssh_key               = var.admin_ssh_key
  admin_password              = var.admin_password
  
  # Connectivity Lab Variables  
  connect_rg_name             = var.connect_rg_name
  connect_location            = var.connect_location
  connect_vnet_name           = var.connect_vnet_name
  connect_vnet_address_space  = var.connect_vnet_address_space
  connect_agents_subnet_name  = var.connect_agents_subnet_name
  connect_agents_subnet_prefix = var.connect_agents_subnet_prefix
  connect_pe_subnet_name      = var.connect_pe_subnet_name
  connect_pe_subnet_prefix    = var.connect_pe_subnet_prefix
  key_vault_name              = var.key_vault_name
  wrong_kv_ip                 = var.wrong_kv_ip
}