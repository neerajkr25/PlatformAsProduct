resource "azurerm_kubernetes_cluster" "aks" {
  name = var.cluster_name
  location = var.location
  resource_group_name = var.resource_group_name
  dns_prefix = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name = "systemnp"
    node_count = var.node_count
    vm_size = var.vm_size
    vnet_subnet_id = var.vnet_subnet_id
    auto_scaling_enabled = false
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin     = "azure"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    load_balancer_sku = "standard"
    network_policy = "azure"
  }
}