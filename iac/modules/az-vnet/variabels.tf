variable "resource_group_name" {
  description = "Name of the resource group to hold the VNet. If creating RG via module, set create_resource_group=true and resource_group_name will be created."
  type        = string
  default     = null
}

variable "vnet_name" {
  default = ""
}
variable "resource_group_location" {
  description = "Location for resource group if module creates it (ignored if create_resource_group=false)."
  type        = string
  default     = null
}

variable "address_space" {
  description = "List of address spaces for the VNet (e.g. [\"10.0.0.0/16\"])."
  type        = list(string)
}

# variable "dns_servers" {
#   description = "Optional list of DNS servers for the VNet."
#   type        = list(string)
#   default     = []
# }

variable "subnets" {
  description = <<EOF
List of subnet objects. Each object supports:
- name (string)
- prefix (string)
- nsg_id (optional string) -> attach existing NSG
- route_table_id (optional string)
- service_endpoints (optional list(string))
- delegations (optional list(object({ name = string, service = string })))
EOF
  type = list(object({
    name            = string
    prefix          = string
    nsg_id          = optional(string)
    route_table_id  = optional(string)
    service_endpoints = optional(list(string))
    delegations     = optional(list(object({ name = string, service = string })))
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# variable "enable_ddos_protection" {
#   description = "Enable DDoS protection plan association (requires ddos plan resource). This module only adds the flag to the vnet resource."
#   type        = bool
#   default     = false
# }

# variable "ddos_protection_plan_id" {
#   description = "ID of a DDoS protection plan if used."
#   type        = string
#   default     = null
# }