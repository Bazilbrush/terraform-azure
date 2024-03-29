resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.state-demo-secure.location
  resource_group_name = azurerm_resource_group.state-demo-secure.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.state-demo-secure.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.state-demo-secure.location
  resource_group_name = azurerm_resource_group.state-demo-secure.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
resource "azurerm_public_ip" "example" {
  name                         = "example-pip"
  location                     = azurerm_resource_group.state-demo-secure.location
  resource_group_name          = azurerm_resource_group.state-demo-secure.name
  allocation_method            = "Dynamic"
}
resource "azurerm_network_security_group" "example" {
  name                = "integration"
  location            = azurerm_resource_group.state-demo-secure.location
  resource_group_name = azurerm_resource_group.state-demo-secure.name
  tags = {
    environment = terraform.workspace
  }
}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_security_rule" "allow_out" {
  name                        = "allow_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.state-demo-secure.name
  network_security_group_name = azurerm_network_security_group.example.name
}
resource "azurerm_network_security_rule" "allow_ssh_jack" {
  name                        = "allow_ssh_jack"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "81.77.68.70/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.state-demo-secure.name
  network_security_group_name = azurerm_network_security_group.example.name
}