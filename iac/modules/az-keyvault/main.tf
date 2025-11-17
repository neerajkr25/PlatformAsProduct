terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" }
  }
}

# Key Vault
resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_deployment      = var.enabled_for_deployment
  enable_rbac_authorization   = var.enable_rbac_authorization

  dynamic "access_policy" {
  for_each = var.enable_rbac_authorization ? [] : (var.access_policies == null ? [] : var.access_policies)
  content {
    tenant_id = lookup(access_policy.value, "tenant_id", var.tenant_id)
    object_id = access_policy.value.object_id

    # permissions are attributes (lists), not nested blocks
    key_permissions         = lookup(access_policy.value, "key_permissions", [])
    secret_permissions      = lookup(access_policy.value, "secret_permissions", [])
    certificate_permissions = lookup(access_policy.value, "certificate_permissions", [])
    storage_permissions     = lookup(access_policy.value, "storage_permissions", [])
  }
}

  network_acls {
    bypass                     = var.network_bypass
    default_action             = var.network_default_action
    ip_rules                   = var.network_ip_rules
    virtual_network_subnet_ids = var.network_virtual_network_subnet_ids
  }

  tags = var.tags
}

# Optional Private Endpoint
resource "azurerm_private_endpoint" "pe" {
  count               = var.private_endpoint.enabled ? 1 : 0
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = var.tags
  depends_on = [azurerm_key_vault.this]
}

# Optional Private DNS zone link and record (if provided)
resource "azurerm_private_dns_zone" "pdns" {
  count               = var.private_endpoint.enabled && var.private_endpoint.create_private_dns ? 1 : 0
  name                = var.private_endpoint.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdns_vnet_link" {
  count                  = var.private_endpoint.enabled && var.private_endpoint.create_private_dns ? 1 : 0
  name                   = "${var.name}-pdnslink"
  resource_group_name    = var.resource_group_name
  private_dns_zone_name  = azurerm_private_dns_zone.pdns[0].name
  virtual_network_id     = var.private_endpoint.vnet_id
  depends_on             = [azurerm_private_dns_zone.pdns]
}

# optional: expose KV access policy resources if caller wants to manage specific policies separately
resource "azurerm_key_vault_access_policy" "extra" {
  count        = length(var.extra_access_policies)
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = lookup(var.extra_access_policies[count.index], "tenant_id", var.tenant_id)
  object_id    = var.extra_access_policies[count.index].object_id

  # Permissions are attributes (lists), not a nested block
  key_permissions         = lookup(var.extra_access_policies[count.index], "key_permissions", [])
  secret_permissions      = lookup(var.extra_access_policies[count.index], "secret_permissions", [])
  certificate_permissions = lookup(var.extra_access_policies[count.index], "certificate_permissions", [])
  storage_permissions     = lookup(var.extra_access_policies[count.index], "storage_permissions", [])

  depends_on = [azurerm_key_vault.this]
}
