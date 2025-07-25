terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "satrostate"
    container_name       = "tfstate"
    key                  = "linux_connectivity_issue_01.tfstate"
  }
}
