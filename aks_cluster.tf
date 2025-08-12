resource "azurerm_subnet" "aksVnetSubnet" {
  name                 = "subnet-${var.ari_prefix}-aks"
  resource_group_name  = var.aks_vnet_rg_name
  virtual_network_name = var.aks_vnet_name
  address_prefixes     = ["${var.aks_subnet_address_prefixes}"]
}

resource "azurerm_route_table" "routeTable" {
  name                = "route-table-${var.ari_prefix}"
  location            = var.location
  resource_group_name = var.resourcegroup

  route = [{
    address_prefix         = "0.0.0.0/0"
    name                   = "aks-fw"
    next_hop_in_ip_address = var.next_hop_ip
    next_hop_type          = "VirtualAppliance"
  }]
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = azurerm_subnet.aksVnetSubnet.id
  route_table_id = azurerm_route_table.routeTable.id
  depends_on     = [azurerm_route_table.routeTable]
}

resource "azurerm_user_assigned_identity" "uai" {
  name                = "${var.ari_prefix}-agentpool"
  location            = var.location
  resource_group_name = var.resourcegroup
}

resource "azurerm_role_assignment" "aksVnetNetworkContributor" {
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_virtual_network.aksVnet.id
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
  depends_on           = [azurerm_user_assigned_identity.uai]
}

resource "azurerm_role_assignment" "routeTableNetworkContributor" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_route_table.routeTable.id
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
  depends_on           = [azurerm_user_assigned_identity.uai]
}

resource "azurerm_kubernetes_cluster" "aksCluster" {
  name                    = "${var.ari_prefix}-aks"
  location                = var.location
  resource_group_name     = var.resourcegroup
  node_resource_group     = var.node_resourcegroup
  dns_prefix              = "${var.ari_prefix}-aks-dns"
  kubernetes_version      = var.aks_version
  private_cluster_enabled = true
  local_account_disabled  = false
  node_os_channel_upgrade = "NodeImage"
  sku_tier                = var.aks_tier
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 48

  maintenance_window_node_os {
    frequency   = "Weekly"
    day_of_week = "Sunday"
    interval    = 2
    start_time  = "1:00"
    duration    = 4
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [var.ad_group_with_access]
    tenant_id              = data.azurerm_client_config.current.tenant_id
  }
  storage_profile {
    blob_driver_enabled = true
  }

  default_node_pool {
    name                        = "system"
    node_count                  = var.ha_enabled == "true" ? 2 : 1
    vm_size                     = var.system_vm_size
    enable_auto_scaling         = false
    vnet_subnet_id              = azurerm_subnet.aksVnetSubnet.id
    temporary_name_for_rotation = "tmpnodepool"
    zones                       = var.av_zones
    os_disk_size_gb             = 32
    os_sku                      = "Ubuntu"
    os_disk_type                = "Ephemeral"
    orchestrator_version        = var.aks_version
  }
  # os_sku AzureLinux has some stability and hostname resolving issues V.2024
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
    outbound_type     = "userDefinedRouting"
  }

  depends_on = [
    azurerm_role_assignment.routeTableNetworkContributor
  ]
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "60m"
  }
  tags = {
    environmentName = var.environment, region = var.location, country = var.country, vertical = "rtl",
    customer        = var.tenant_name, environment = var.environment_type, dataType = "CustomerUse", pciCompliance = "false",
    owner           = var.owner, expirationDate = var.expiration_date, costCenter = var.cost_center,
    costAllocation  = var.cost_allocation, environmentReferenceID = var.env_reference_id
  }
}
