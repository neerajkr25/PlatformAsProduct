##############################################################
# Resource Group
##############################################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Project = "TIP"
    Environment = "Stage"
  }
}

##############################################################
# Vnet
##############################################################
module "vnet" {
  source = "../../modules/az-vnet"
  vnet_name                = var.vnet_name
  resource_group_name      = var.resource_group_name
  resource_group_location  = var.location
  address_space            = var.address_space
  tags = {
    Project = "ERDC"
    Env     = "Staging"
  }

  subnets = [
    # AKS subnets
    {
      name   = "snet-stg-k8s-system"
      prefix = "10.52.80.0/24"
      delegation = {
        name    = "aks-delegation"
        service = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    },
    {
      name   = "snet-stg-k8s-workload"
      prefix = "10.52.88.0/21"
      delegation = {
        name    = "aks-delegation"
        service = "Microsoft.ContainerService/managedClusters"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    },
    # for ohter resources
    {
      name   = "snet-stg-ai"
      prefix = "10.52.81.64/26"
    },
    {
      name   = "snet-stg-appgw"
      prefix = "10.52.81.224/27"
    },
    {
      name   = "subnet-stg-db"
      prefix = "10.52.81.128/26"
    },
    {
      name   = "AzureBastionSubnet"
      prefix = "10.52.81.192/27"
    }
  ]
}

##############################################################
# Bastion Host 
##############################################################
module "bastion_host" {
  source = "../../modules/az-bastion-host"
  bastion_host_public_ip = var.bastion_host_public_ip_name
  location = var.location
  resource_group_name = var.resource_group_name
  bastion_host_name = var.bastion_host_name
  subnet_id = module.vnet.subnet_ids["AzureBastionSubnet"]
  ip_connect_enabled = var.bastion_host_ip_connect_enabled
}

##############################################################
# Jumo box to connect AKS API 
##############################################################
module "jump_box" {
  source               = "../../modules/az-jump-box"
  resource_group_name  = var.resource_group_name
  location             = var.location
  vm_name              = "aks-jump-stg-01"
  vm_size              = "Standard_B2s"
  admin_username       = "sudoadmin"
  admin_ssh_public_key = file(var.local_ssh_pubkey_path) 
  vnet_subnet_id       = module.vnet.subnet_ids["snet-stg-ai"]
  create_public_ip     = false
  allowed_ssh_cidr     = "X.X.X.X/32"
  # aks_resource_id      = azurerm_kubernetes_cluster.aks.id  # optional; set if you want role assignment
}

##############################################################
# Public Application Gateway
##############################################################
module "app_gateway" {
  source              = "../../modules/az-app-gateway"
  name                = var.appgw
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["snet-stg-appgw"]
  backend_fqdns       = ["poc.powerdreams.app"]
  tags = {
    environment = "stg-temp"
    owner       = "Neeraj"
    project     = "TIP"
  }
}

##############################################################
# Private AKS cluster
##############################################################
module "aks" {
  source = "../../modules/az-aks"
  acr_name             = var.acr_name
  cluster_name         = var.cluster_name
  kubernetes_version   = var.kubernetes_version
  location             = var.location
  resource_group_name  = var.resource_group_name
  node_resource_group  = "rg-stg-tip-nodes"
  env                  = "stg"

  system_min_count     = 1
  system_max_count     = 3
  system_subnet_id     = module.vnet.subnet_ids["snet-stg-k8s-system"]

  workload_min_count   = 1
  workload_max_count   = 5
  workload_subnet_id   = module.vnet.subnet_ids["snet-stg-k8s-workload"]
}

##############################################################
# NETWORK CONTRIBUTOR ROLE ASSIGNMENT for AKS
##############################################################
locals {
  aks_subnets = {
    system   = module.vnet.subnet_ids["snet-stg-k8s-system"]
    workload = module.vnet.subnet_ids["snet-stg-k8s-workload"]
  }
}
resource "azurerm_role_assignment" "kubelet_network_contrib" {
  for_each                        = local.aks_subnets
  scope                            = each.value
  role_definition_name             = "Network Contributor"
  principal_id                     = module.aks.kubelet_identity_object_id
  skip_service_principal_aad_check = true

  depends_on = [
    module.vnet,
    module.aks
  ]
}

##############################################################
# Virtual Machines (AI)
##############################################################
variable "local_ssh_pubkey_path" {
  type    = string
  default = "C:/Users/neeraj.kumar/.ssh/id_rsa.pub"
}

module "first_ai_vm" {
  source               = "../../modules/az-vm"
  resource_group_name  = var.resource_group_name
  location             = var.location
  vm_name              = "vm-stg-uaen-tip-001"
  vm_size              = "Standard_B2s"
  admin_username       = "sudoadmin"
  admin_ssh_public_key = file(var.local_ssh_pubkey_path) 
  vnet_subnet_id       = module.vnet.subnet_ids["snet-stg-ai"]
  create_public_ip     = false
  allowed_ssh_cidr     = "X.X.X.X/32"
  # aks_resource_id      = azurerm_kubernetes_cluster.aks.id  # optional; set if you want role assignment
}

# module "second_ai_vm" {
#   source               = "../../modules/az-vm"
#   resource_group_name  = var.resource_group_name
#   location             = var.location
#   vm_name              = "vm-stg-uaen-tip-002"
#   vm_size              = "Standard_D4ds_v5"
#   admin_username       = "sudoadmin"
#   admin_ssh_public_key = file(var.local_ssh_pubkey_path) 
#   vnet_subnet_id       = module.vnet.subnet_ids["snet-stg-ai"]
#   create_public_ip     = false
#   allowed_ssh_cidr     = "X.X.X.X/32"
#   # aks_resource_id      = azurerm_kubernetes_cluster.aks.id  # optional; set if you want role assignment
# }


##############################################################
# Azure Postgress Database
##############################################################
module "pg_flex" {
  source              = "../../modules/az-pgdb-flexible"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = "pg-tip-stg-uaen-01"
  admin_username      = "pgsudoadmin"
  admin_password      = var.pg_admin_password
  sku_name            = "GP_Standard_D2s_v3"
  storage_mb          = 32768
  vnet_id             = module.vnet.vnet_id
  private_subnet_id   = module.vnet.subnet_ids["subnet-stg-db"]
  tags = {
    env = "stg"
    app = "tip"
  }
  # Optionally disable public network access automatically (requires az CLI)
  disable_public_network_access = true
}

##############################################################
# Azure Key Vault
##############################################################
data "azurerm_client_config" "current" {}
module "kv" {
  source              = "../../modules/az-keyvault"
  name                = "kv-tip-stg-uaen"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enable_rbac_authorization = true
  # network rules -- allow only from staging jump box and the devops IP
  network_ip_rules    = ["2.50.151.43/32"]
  # network_virtual_network_subnet_ids = [module.vnet.subnet_ids["snet-stg-k8s-workload"]]
  private_endpoint = {
    enabled               = true
    subnet_id             = module.vnet.subnet_ids["snet-stg-k8s-workload"]
    vnet_id               = module.vnet.vnet_id
    create_private_dns    = true
    private_dns_zone_name = "privatelink.vaultcore.azure.net"
  }
  tags = {
    Project = "tip"
    Env     = "stg"
    ManagedBy = "Terraform"
  }
}

##############################################################
# Azure Log workspace
##############################################################
# module "law" {
#   source              = "../../modules/az-law"
#   name                = "law-tip-stg-uaen"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
#   daily_quota_gb      = 0
#   tags = {
#     Project = "tip"
#     Env     = "stg"
#   }
# }
# output "law_customer_id" {
#   value = module.law.customer_id
# }
