resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = var.address_space
  # dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  tags                = var.tags

  # dynamic "ddos_protection_plan" {
  #   for_each = var.enable_ddos_protection && var.ddos_protection_plan_id != null ? [1] : []
  #   content {
  #     id = var.ddos_protection_plan_id
  #   }
  # }
}

# Create subnets dynamically
resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.this.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]

  # # optional attributes
  # network_security_group_id = lookup(each.value, "nsg_id", null)
  # route_table_id            = lookup(each.value, "route_table_id", null)
  # service_endpoints        = lookup(each.value, "service_endpoints", null)

  # dynamic "delegation" {
  #   for_each = lookup(each.value, "delegations", [])
  #   content {
  #     name = delegation.value.name
  #     service_delegation {
  #       name    = delegation.value.service
  #       actions = delegation.value.actions == null ? [] : delegation.value.actions
  #     }
  #   }
  # }

  # tags = var.tags
}


