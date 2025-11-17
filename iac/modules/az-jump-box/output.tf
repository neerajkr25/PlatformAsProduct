output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "vm_private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}

output "vm_public_ip" {
  value = var.create_public_ip && length(azurerm_public_ip.this) > 0 ? azurerm_public_ip.this[0].ip_address : ""
}

output "vm_managed_identity_object_id" {
  value = azurerm_linux_virtual_machine.this.identity[0].principal_id
  description = "Principal ID for managed identity (useful for role assignment debugging)"
}

