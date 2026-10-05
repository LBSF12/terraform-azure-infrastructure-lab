resource "azurerm_virtual_network" "lab" {
  name                = "lab-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "management" {
  name                 = "management-subnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "application" {
  name                 = "application-subnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.2.0/24"]
}