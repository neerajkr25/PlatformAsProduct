variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where the Application Gateway will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier for the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity (number of instances)"
  type        = number
  default     = 2
}

variable "backend_fqdns" {
  description = "List of backend FQDNs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to assign to the Application Gateway"
  type        = map(string)
  default     = {}
}
