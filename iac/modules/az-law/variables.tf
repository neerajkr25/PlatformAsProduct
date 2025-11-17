variable "name" {
  description = "Log Analytics workspace name"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 100
    error_message = "Workspace name must be 1-100 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group where workspace will be created"
  type        = string
}

variable "location" {
  description = "Azure location (e.g. uaenorth)"
  type        = string
}

variable "sku" {
  description = "Workspace SKU. e.g. PerGB2018 (pay-as-you-go), Free"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Optional daily quota in GB. Set to 0 to disable. Only for certain SKUs."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags applied to the workspace"
  type        = map(string)
  default     = {}
}
