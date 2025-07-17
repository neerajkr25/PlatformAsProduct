resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "dev-web-subnet" {
  name          = "dev-web-subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "dev-app-subnet" {
  name = "dev-app-subnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes = ["10.0.2.0/24"]
}