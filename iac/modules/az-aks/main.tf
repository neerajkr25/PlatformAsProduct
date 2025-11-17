##############################################################
# Azure Container Registry
##############################################################
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

##############################################################
# AKS Cluster
##############################################################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  node_resource_group = var.node_resource_group

  private_cluster_enabled           = true
  private_cluster_public_fqdn_enabled = false

  default_node_pool {
    name               = "system"
    vm_size            = var.system_vm_size
    type               = "VirtualMachineScaleSets"
    zones              = var.zones

    auto_scaling_enabled = true
    min_count            = var.system_min_count
    max_count            = var.system_max_count

    vnet_subnet_id = var.system_subnet_id

    node_labels = {
      "workload-type" = "akssystem"
      "env"           = var.env
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  service_mesh_profile {
    mode                             = "Istio"
    revisions                        = ["asm-1-25"]
    internal_ingress_gateway_enabled = true
  }

  tags = {
    Env = var.env
  }
}

##############################################################
# AKS Workload Node Pool
##############################################################
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size              = var.workload_vm_size
  mode                 = "User"
  os_type              = "Linux"
  orchestrator_version = var.kubernetes_version
  zones                = var.zones

  auto_scaling_enabled = true
  min_count            = var.workload_min_count
  max_count            = var.workload_max_count

  vnet_subnet_id = var.workload_subnet_id

  node_labels = {
    "workload-type" = "aks-workload"
    "env"           = var.env
  }

  tags = {
    Purpose = "ApplicationWorkloads"
    Env     = var.env
  }
}

##############################################################
# Role assignment (ACR Pull)
##############################################################
resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
