variable "name" {
  description = "Key Vault name (globally unique for KV)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
  description = "AAD tenant id that will be the owner of the vault"
}

variable "sku_name" {
  type    = string
  default = "standard"   # "standard" or "premium"
}

variable "soft_delete_retention_days" {
  default = "7"
}

variable "purge_protection_enabled" {
  type    = bool
  default = false
}

variable "enabled_for_disk_encryption" {
  type    = bool
  default = false
}

variable "enabled_for_template_deployment" {
  type    = bool
  default = false
}

variable "enabled_for_deployment" {
  type    = bool
  default = false
}

variable "enable_rbac_authorization" {
  type    = bool
  default = true
  description = "Use Azure RBAC for Key Vault access control (recommended). If false, module will accept access_policies."
}

# List of access policies (only used if enable_rbac_authorization = false)
# Example element:
# {
#   object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#   tenant_id = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
#   secret_permissions = ["get","list"]
#   key_permissions = ["get"]
# }
variable "access_policies" {
  type    = list(object({
    object_id             = string
    tenant_id             = optional(string)
    secret_permissions    = optional(list(string))
    key_permissions       = optional(list(string))
    certificate_permissions = optional(list(string))
    storage_permissions   = optional(list(string))
  }))
  default = null
}

variable "extra_access_policies" {
  type = list(object({
    object_id             = string
    tenant_id             = optional(string)
    secret_permissions    = optional(list(string))
    key_permissions       = optional(list(string))
    certificate_permissions = optional(list(string))
    storage_permissions   = optional(list(string))
  }))
  default = []
  description = "Additional access policies created as separate resources (useful to add/remove without replacing KV)"
}

variable "network_bypass" {
  type    = string
  default = "AzureServices"
}

variable "network_default_action" {
  type    = string
  default = "Deny"
}

variable "network_ip_rules" {
  type    = list(string)
  default = []
}

variable "network_virtual_network_subnet_ids" {
  type    = list(string)
  default = []
  description = "VNet subnet ids allowed in network ACLs (service endpoints). Note: For private endpoint, use private_endpoint config below."
}

variable "private_endpoint" {
  type = object({
    enabled                = bool
    subnet_id              = optional(string)
    vnet_id                = optional(string)
    create_private_dns     = optional(bool)
    private_dns_zone_name  = optional(string)
  })
  default = {
    enabled               = false
    subnet_id             = null
    vnet_id               = null
    create_private_dns    = false
    private_dns_zone_name = "privatelink.vaultcore.azure.net"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
