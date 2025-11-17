variable "acr_name" {}
variable "cluster_name" {}
variable "kubernetes_version" {}
variable "location" {}
variable "resource_group_name" {}
variable "node_resource_group" {}
variable "env" {}

variable "system_vm_size" {
  default = "Standard_D4ds_v5"
}
variable "system_min_count" {}
variable "system_max_count" {}
variable "system_subnet_id" {}

variable "workload_vm_size" {
  default = "Standard_D4ds_v5"
}
variable "workload_min_count" {}
variable "workload_max_count" {}
variable "workload_subnet_id" {}

variable "zones" {
  type    = list(number)
  default = [1, 2, 3]
}
