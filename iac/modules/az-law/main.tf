terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                 = var.sku                # "PerGB2018" or "Free" etc.
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  tags = var.tags
}

# Get the workspace keys (sensitive)
# data "azurerm_log_analytics_workspace_shared_keys" "this" {
#   workspace_id = azurerm_log_analytics_workspace.this.id
# }

# Optional: (commented) sample to create diagnostic settings sending logs to this workspace
# resource "azurerm_monitor_diagnostic_setting" "example" {
#   name               = "diag-${azurerm_log_analytics_workspace.this.name}"
#   target_resource_id = <target-resource-id>   # e.g., azurerm_application_insights.myapp.id or an ARM resource id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
#   logs {
#     category = "Administrative"
#     enabled  = true
#     retention_policy {
#       enabled = false
#       days    = 0
#     }
#   }
# }

