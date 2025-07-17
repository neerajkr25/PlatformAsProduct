terraform {
  backend "azurerm" {
    resource_group_name = "rg-pp-001"
    storage_account_name = "ppplatformstorageaccount"
    container_name = "dev-tf"
  }
}