provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_msi = true
}

terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "1.6.6"
    }
  }
}