variable "subscription_id" {
  default = "b67ea722-4d9a-4530-baea-eedf25855247"
}

variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" {
  type = list(string)
}

#### k8s networing ##########
variable "service_cidr" {
  default = "10.240.0.0/16"
}

variable "dns_service_ip" {
  default = "10.240.0.10"
}

variable "docker_bridge_cidr" {
  default = "172.17.0.1/16"
}
