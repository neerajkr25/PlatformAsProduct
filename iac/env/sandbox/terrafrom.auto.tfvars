resource_group_name = "rg-tip-stg-uaen"
location            = "uaenorth"
vnet_name           = "vnet-tip-stg-uaen"
address_space       = ["10.52.80.0/20"]
cluster_name        = "aks-tip-stg-uaen"
kubernetes_version  = "1.32.7"
system_node_count   = 2
acr_name            = "acrtipstg001"
system_min_count    = "2"
system_max_count    = "4"
workload_min_count  = "2"
workload_max_count  = "4"

bastion_host_public_ip_name = "pip-tip-stg-uaen-bastion"
bastion_host_name = "bastion-tip-stg-auen"
bastion_host_ip_connect_enabled = true


appgw = "agw-tip-stg-uaen-01"


pg_admin_password = "Jndhf4343hh^%373n66ernd"