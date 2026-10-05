resource "azurerm_network_security_group" "application" {
  name                = "application-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = {
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_network_security_rule" "allow_ssh_from_management" {
  name      = "Allow-SSH-From-Management"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "10.10.1.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.application.name
}