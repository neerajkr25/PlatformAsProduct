variable "subscription_id" {
  default = "b67ea722-4d9a-4530-baea-eedf25855247"
}

variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" {
  type = list(string)
}
