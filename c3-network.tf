# This section is required to set the azurerm provider version to greater than 2.49.0. Versions between 2.42.0 and 2.49.0 have an issue 
# with authentication and this is tracked in https://github.com/terraform-providers/terraform-provider-azurerm/issues/10292

resource "azurerm_resource_group" "myrg" {
  name     = "${var.prefix}_resources"
  location = var.region
}

resource "azurerm_virtual_network" "myvnet" {
  name                = "${var.prefix}-network"
  resource_group_name =  azurerm_resource_group.myrg.name
  location            =  azurerm_resource_group.myrg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "internal"
  virtual_network_name =  azurerm_virtual_network.myvnet.name
  resource_group_name  =  azurerm_resource_group.myrg.name
  address_prefixes     = [ "10.0.0.0/24" ]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "ssh" {
    name                = "ssh-sg"
    location            = var.region
    resource_group_name = azurerm_resource_group.myrg.name

    security_rule {
        name                       = "SSH"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes      = var.cloudshell_public_ip
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.ssh.id
}