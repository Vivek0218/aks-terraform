# Network security group
resource "azurerm_network_security_group" "vaas_nsg" {
  count               = var.fcx_mtls == "true" ? 1 : 0
  name                = "${var.ari_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resourcegroup
  depends_on = [
    azurerm_subnet.aksVnetSubnet
  ]
}

resource "azurerm_network_security_rule" "ngs_allow_rabbitmq_port" {
  count                       = var.fcx_mtls == "true" ? 1 : 0
  name                        = "allow_rabbitmq_port"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5672"
  source_address_prefix       = "10.244.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup
  network_security_group_name = azurerm_network_security_group.vaas_nsg[0].name
  depends_on = [
    azurerm_network_security_group.vaas_nsg
  ]
}

resource "azurerm_network_security_rule" "ngs_block_rabbitmq_port" {
  count                       = var.fcx_mtls == "true" ? 1 : 0
  name                        = "allow_in_http_80"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5672"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resourcegroup
  network_security_group_name = azurerm_network_security_group.vaas_nsg[0].name
  depends_on = [
    azurerm_network_security_group.vaas_nsg
  ]
}

# NGS association with subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  count                     = var.fcx_mtls == "true" ? 1 : 0
  subnet_id                 = azurerm_subnet.aksVnetSubnet.id
  network_security_group_id = azurerm_network_security_group.vaas_nsg[0].id
  depends_on = [
    azurerm_network_security_group.vaas_nsg,
    azurerm_subnet.aksVnetSubnet
  ]
}
