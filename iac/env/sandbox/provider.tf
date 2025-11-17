terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.30.0"
    }
  }

  # Recommended: do NOT hardcode backend secrets in code for security.
  # Replace the values below OR prefer to pass them with `-backend-config` to `terraform init`.
  backend "azurerm" {
    resource_group_name  = "rg-pac-neeraj-001"     
    storage_account_name = "uaenstgpac002"  
    container_name       = "pac-tf-001"                
    key                  = "pac-terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
