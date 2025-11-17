output "id" {
  description = "Log Analytics workspace resource id"
  value       = azurerm_log_analytics_workspace.this.id
}

# output "customer_id" {
#   description = "Customer ID (workspace ID) to use when configuring agents"
#   value       = azurerm_log_analytics_workspace.this.customer_id
# }

# output "primary_shared_key" {
#   description = "Primary shared key for the workspace (sensitive)"
#   value       = data.azurerm_log_analytics_workspace_shared_keys.this.primary_shared_key
#   sensitive   = true
# }

output "name" {
  description = "Workspace name"
  value       = azurerm_log_analytics_workspace.this.name
}
