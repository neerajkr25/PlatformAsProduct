output "postgresql_flexible_server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}

output "postgresql_flexible_server_fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.this.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.pdns.id
}
