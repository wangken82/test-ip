# Create public IPs
resource "azurerm_public_ip" "bastion" {
    name                         = "bastion-public-ip"
    location                     = var.region
    resource_group_name          = azurerm_resource_group.myrg.name
    allocation_method            = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "bastion" {
    name                      = "bastion-nic"
    location                  = var.region
    resource_group_name       = azurerm_resource_group.myrg.name

    ip_configuration {
        name                          = "bastion-public"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.101"
        public_ip_address_id          = azurerm_public_ip.bastion.id
        primary                       = "true"
    }

    ip_configuration {
        name                          = "bastion-private"
        subnet_id                     = azurerm_subnet.mysubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.0.100"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.bastion.id
    network_security_group_id = azurerm_network_security_group.ssh.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "bastion" {
    name                  = "bastion"
    location              = var.region
    resource_group_name   = azurerm_resource_group.myrg.name
    network_interface_ids = [azurerm_network_interface.bastion.id]
    size                  = "Standard_D2s_v3"

    os_disk {
        name              = "bastion-os-disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
        #disk_size_gb      = "128"
    }

    source_image_reference {
        publisher = "SUSE"
        offer     = "sles-sap-12-sp5"
        sku       = "gen2"
        version   = "latest"
    }

    computer_name  = "bastion"
    admin_username = "azureadmin"
    #custom_data    = file("<path/to/file>")

    admin_ssh_key {
        username       = "azureadmin"
        public_key     = file("~/.ssh/lab_rsa.pub")
    }
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion.ip_address
}