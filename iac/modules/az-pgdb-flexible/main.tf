
# ---------------------------
# PostgreSQL Flexible Server
# ---------------------------
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  sku_name               = var.sku_name
  version                = var.postgres_version
  storage_mb             = var.storage_mb
  backup_retention_days  = var.backup_retention_days
  tags                   = var.tags
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }
  zone = "1"
  # high_availability {
  #   mode = "SameZone"
  #   }
  # start with public enabled to allow Private Endpoint creation,
  # later we optionally disable public access.
  public_network_access_enabled = true

  # high availability config (optional)
  # availability_zone = var.availability_zone

  # optional maintenance window
  maintenance_window {
    day_of_week = var.maintenance_day_of_week
    start_hour  = var.maintenance_start_hour
  }
}

# ---------------------------
# Private DNS Zone (privatelink)
# ---------------------------
resource "azurerm_private_dns_zone" "pdns" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "pdns_link" {
  name                  = "${var.server_name}-pdnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pdns.name
  virtual_network_id    = var.vnet_id
  depends_on = [azurerm_private_dns_zone.pdns]
}

# ---------------------------
# Private Endpoint
# ---------------------------
resource "azurerm_private_endpoint" "this" {
  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  private_service_connection {
    name                           = "${var.server_name}-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    # target subresource for Flexible Server
    subresource_names = ["postgresqlServer"]
  }

  tags = var.tags
  depends_on = [azurerm_postgresql_flexible_server.this, azurerm_private_dns_zone_virtual_network_link.pdns_link]
}

# NOTE:
# Azure typically populates the Private DNS zone with the required A/AAAA records
# as part of the Private Endpoint provisioning. If your environment requires manual
# record creation, you can add azurerm_private_dns_a_record resources here.
#
# The provider may also create Private DNS zone group entries; for most cases the
# azurerm_private_endpoint above is enough and the DNS zone link will make resolution work.

# ---------------------------
# Optional: disable public network access (automated)
# ---------------------------

# resource "null_resource" "disable_public_network" {
#   count = var.disable_public_network_access ? 1 : 0

#   # Ensure private endpoint created before attempting to disable public access
#   depends_on = [azurerm_private_endpoint.this]

#   provisioner "local-exec" {
#     # Requires `az` CLI logged in and correct subscription set (or use az account set before running TF)
#     command = <<EOT
#       az postgres flexible-server update \
#         --resource-group "${var.resource_group_name}" \
#         --name "${var.server_name}" \
#         --public-network-access Disabled
#     EOT
#   }

#   # cheap trigger to re-run if the server name changes
#   triggers = {
#     server_id = azurerm_postgresql_flexible_server.this.id
#   }
# }
