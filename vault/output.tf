output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "aks_nodepool_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].name
}

output "aks_nodepool_count" {
  value = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].node_count
}
