data "azurerm_virtual_network" "aksVnet" {
  name                = var.aks_vnet_name
  resource_group_name = var.aks_vnet_rg_name
}

data "azurerm_private_endpoint_connection" "kubeApiServer" {
  name                = "kube-apiserver"
  resource_group_name = azurerm_kubernetes_cluster.aksCluster.node_resource_group
}

data "azurerm_network_interface" "aksNic" {
  name                = data.azurerm_private_endpoint_connection.kubeApiServer.network_interface[0].name
  resource_group_name = azurerm_kubernetes_cluster.aksCluster.node_resource_group
}

data "azurerm_client_config" "current" {
}