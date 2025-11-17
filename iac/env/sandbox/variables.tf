variable "subscription_id" {
  default = ""
}

variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" {
  type = list(string)
}

##### k8s vars ##########
#create variables.tf
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}
variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}
variable "acr_name" {
  type        = string
  description = "ACR name"
}
variable "system_min_count" {
  default = ""
}
variable "system_max_count" {
  default = ""
}
variable "workload_min_count" {
  default = ""
}
variable "workload_max_count" {
  default = ""
}


# Bastion host vars
variable "bastion_host_public_ip_name" {
  type = string
  description = "Public IP name for the bastion host"
}

variable "bastion_host_name" {
  type = string
  description = "Name for the bastion host"
}

variable "bastion_host_ip_connect_enabled" {
  type = bool
  description = "Boolean if IP connect is enabled for the bastion host"
}

# Application gateway 
variable "appgw" {
  default = ""
}

# PG-DB
variable "pg_admin_password" {
  default = ""
}