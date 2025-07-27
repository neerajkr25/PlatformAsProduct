#### Create networking with 2 subnets #####
module "vnet" {
  source              = "../../modules/vnet"
  vnet_name           = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

#### Create AKS cluster ######
module "dev-aks" {
  source              = "../../modules/aks"
  cluster_name        = "dev-aks-cluster"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "devaks"
  node_count          = 2
  vm_size             = "standard_a2_v2"
  vnet_subnet_id = module.vnet.dev_app_subnet_id
  service_cidr        = var.service_cidr
  dns_service_ip      = var.dns_service_ip
  tags = {
    env     = "dev"
    project = "platformAsProduct"
  }
}
