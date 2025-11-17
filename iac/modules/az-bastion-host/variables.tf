# Variable for the name of the Public IP address for the Bastion Host.
variable "bastion_host_public_ip" {
  description = "The name for the Public IP address resource used by the Azure Bastion host."
  type        = string
}

# Variable for the Azure region where resources will be deployed.
variable "location" {
  description = "The Azure region where the Bastion Host and its associated resources will be created."
  type        = string
}

# Variable for the name of the resource group.
variable "resource_group_name" {
  description = "The name of the resource group where the Bastion Host and its associated resources will be created."
  type        = string
}


# Variable for the name of the Bastion Host resource.
variable "bastion_host_name" {
  description = "The name for the Azure Bastion host resource."
  type        = string
}

variable "ip_connect_enabled" {
  description = "Whether IP connect is enabled. Defaults to true"
  type        = bool
  default = true
}

# Variable for the name of the IP configuration within the Bastion Host.
variable "ip_config_name" {
  description = "The name for the IP configuration block within the Azure Bastion host resource."
  type        = string
  default     = "BastionIpConfig"
}

# Variable for the Subnet ID where the Bastion Host will reside.
variable "subnet_id" {
  description = "The full resource ID of the subnet where the Azure Bastion host will be deployed. This subnet MUST be named 'AzureBastionSubnet'."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}