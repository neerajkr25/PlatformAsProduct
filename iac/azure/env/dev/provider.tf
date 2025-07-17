terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "1.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}