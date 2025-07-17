output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "dev_web_subnet_id" {
  value = azurerm_subnet.dev-web-subnet.id
}

output "dev_app_subnet_id" {
  value = azurerm_subnet.dev-app-subnet.id
}