variable "resource_group_name" {
  type        = string
  description = "Resource group where the server and DNS zone will be created"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "server_name" {
  type        = string
  description = "PostgreSQL flexible server name"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the server"
}

variable "admin_password" {
  type        = string
  description = "Administrator password (sensitive)"
  sensitive   = true
}

variable "sku_name" {
  type        = string
  description = "SKU name (example: Standard_D2s_v3)"
  default     = "Standard_B1ms"
}

variable "postgres_version" {
  type        = string
  description = "Postgres version"
  default     = "16"
}

variable "storage_mb" {
  type        = number
  description = "Storage in MB"
  default     = 32768
}

variable "backup_retention_days" {
  type        = number
  default     = 7
}

variable "availability_zone" {
  type        = string
  description = "Optional availability zone for the server (e.g. '1')"
  default     = null
}

variable "maintenance_day_of_week" {
  type        = number
  default     = 0
}

variable "maintenance_start_hour" {
  type        = number
  default     = 0
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of the private DNS zone to create / use"
  default     = "privatelink.postgres.database.azure.com"
}

variable "vnet_id" {
  type        = string
  description = "ID of the virtual network to link the private DNS zone to"
}

variable "private_subnet_id" {
  type        = string
  description = "Subnet ID where the Private Endpoint will be created (must not have delegations to FlexibleServer)"
}

variable "disable_public_network_access" {
  type        = bool
  description = "If true, the module will attempt to disable public network access after creating the private endpoint (requires az CLI)."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags for all resources"
  default     = {}
}
