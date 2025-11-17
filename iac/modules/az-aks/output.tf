output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "kubelet_identity_object_id" {
  description = "Kubelet managed identity object id"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
