# File: outputs.tf
output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

# output "subnets" {
#   description = "Map of subnets keyed by subnet name with id/name/prefix"
#   value       = local.subnet_map
# }

output "subnet_ids" {
  description = "Map of subnet name -> id"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}