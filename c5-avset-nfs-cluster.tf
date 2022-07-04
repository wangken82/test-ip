#create avset nfs, and 2 new VMS nfs0/1 each with 2 data luns
resource "azurerm_availability_set" "nfs" {
  name                = "nfs-avSet"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  platform_fault_domain_count = "2"
}

# Create network interfaces
resource "azurerm_network_interface" "nfs-0" {
    name                      = "nfs-0-nic"
    location                  = var.region
    resource_group_name       = azurerm_resource_group.myrg.name

    ip_configuration {
        name                          = "nfs-0-private"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.6"
        primary                       = "true"
    }
}
resource "azurerm_network_interface" "nfs-1" {
    name                      = "nfs-1-nic"
    location                  = var.region
    resource_group_name       = azurerm_resource_group.myrg.name

    ip_configuration {
        name                          = "nfs-1-private"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.7"
        primary                       = "true"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nfs-0" {
    network_interface_id      = azurerm_network_interface.nfs-0.id
    network_security_group_id = azurerm_network_security_group.ssh.id
}
resource "azurerm_network_interface_security_group_association" "nfs-1" {
    network_interface_id      = azurerm_network_interface.nfs-1.id
    network_security_group_id = azurerm_network_security_group.ssh.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "nfs-0" {
    name                  = "nfs-0"
    location              = var.region
    resource_group_name   = azurerm_resource_group.myrg.name
    network_interface_ids = [azurerm_network_interface.nfs-0.id]
    size                  = "Standard_DS2_v2"

    os_disk {
        name              = "nfs-0-osdisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb      = "100"
    }

    source_image_reference {
        publisher = var.publisher
        offer     = var.offer
        sku       = var.sku
        version   = var._version
    }

    computer_name  = "nfs-0"
    availability_set_id = azurerm_availability_set.nfs.id
    admin_username = "azureadmin"
#    custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }
}