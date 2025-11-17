output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "private_endpoint_id" {
  value = length(azurerm_private_endpoint.pe) > 0 ? azurerm_private_endpoint.pe[0].id : ""
}

output "private_dns_zone_id" {
  value = length(azurerm_private_dns_zone.pdns) > 0 ? azurerm_private_dns_zone.pdns[0].id : ""
}
