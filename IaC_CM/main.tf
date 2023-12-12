resource "azurerm_resource_group" "practice_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.env
    Team        = "DiegoDevOps"
  }

}

resource "azurerm_virtual_network" "practice_vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"] #10.0.0.0/16
  location            = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name
}

resource "azurerm_subnet" "practice_subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.practice_rg.name
  virtual_network_name = azurerm_virtual_network.practice_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "practice_subnet2" {
  name                 = var.subnet2_name
  resource_group_name  = azurerm_resource_group.practice_rg.name
  virtual_network_name = azurerm_virtual_network.practice_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "practice_pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.practice_rg.name
  location            = azurerm_resource_group.practice_rg.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = var.env
  }
}

resource "azurerm_public_ip" "practice_prip" {
  name                = var.private_ip_name
  resource_group_name = azurerm_resource_group.practice_rg.name
  location            = azurerm_resource_group.practice_rg.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_security_group" "practice_public_nsg" {
  name                = var.publicNsg
  location            = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name
  security_rule {
    name                       = "forPublic"
    description                = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.sourceip
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "forPrivate"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "practice_private_nsg" {
  name                = var.privateNsg
  location            = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name

  security_rule {
    name                       = "forPrivate"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "practice_public_nic" {
  name                = "PracticeInterface1"
  location            = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name
 
  ip_configuration {
    name                          = "PracticePublicIp"
    subnet_id                     = azurerm_subnet.practice_subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  azurerm_public_ip.practice_pip.id
  }

  tags = {
    environment = var.env
  }
}

resource "azurerm_network_interface" "practice_private_nic" {
  name                = "PracticeInterface2"
  location            = azurerm_resource_group.practice_rg.location
  resource_group_name = azurerm_resource_group.practice_rg.name

  ip_configuration {
    name                          = "PracticePrivateID"
    subnet_id                     = azurerm_subnet.practice_subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  azurerm_public_ip.practice_prip.id

  }

  tags = {
      environment = var.env
    }
}

resource "azurerm_subnet_network_security_group_association" "securitySubnetPublic" {
  subnet_id                 = azurerm_subnet.practice_subnet1.id
  network_security_group_id = azurerm_network_security_group.practice_public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "securitySubnetPrivate" {
  subnet_id                 = azurerm_subnet.practice_subnet2.id
  network_security_group_id = azurerm_network_security_group.practice_private_nsg.id
}

resource "azurerm_linux_virtual_machine" "practicePublic_vm" {
  name                          = "Linux"
  location                      = azurerm_resource_group.practice_rg.location
  resource_group_name           = azurerm_resource_group.practice_rg.name
  network_interface_ids         = [azurerm_network_interface.practice_public_nic.id]
  size                          = "Standard_DS1_v2"
  admin_username                = "ansibleUser"
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "Linux-OSdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "ansibleUser"
    public_key = file("./practice_private_key.pub")
  }

  tags = {
    environment = var.env
  }

}

 data "cloudinit_config" "ansible" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "userdata_ansible.cfg"
    content_type = "text/cloud-config"
    content      = file("script/userdata_ansible.cfg")
      }
  }

resource "azurerm_linux_virtual_machine" "practicePrivate_vm" {
  name                          = "LinuxAnsible"
  location                      = azurerm_resource_group.practice_rg.location
  resource_group_name           = azurerm_resource_group.practice_rg.name
  network_interface_ids         = [azurerm_network_interface.practice_private_nic.id]
  size                          = "Standard_DS1_v2"
  admin_username                = "ansibleUser"
  custom_data = data.cloudinit_config.ansible.rendered


  admin_ssh_key {
    username   = "ansibleUser"
    public_key = file("./practice_public_key.pub")
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "LinuxAnsible-OSdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  connection {
    type        = "ssh"
    user        = "ansibleUser"
    private_key = file("./practice_public_key")
    host        = self.public_ip_address
  }

  provisioner "file" {
    source      = "./practice_private_key"
    destination = "/home/ansibleUser/.ssh/practice_private_key"
  }

  provisioner "file" {
    source      = "./project/index.html"
    destination = "/home/ansibleUser/index.html"
  }

  provisioner "file" {
    source      = "./script/install_apache.yml"
    destination = "/home/ansibleUser/install_apache.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/practice_private_key",
      "echo HelloExecutingRemote",
      "cloud-init status --wait",        
      "ansible-playbook -i ansibleUser@${azurerm_network_interface.practice_public_nic.private_ip_address}, --private-key ~/.ssh/practice_private_key install_apache.yml -u ansibleUser --become --ssh-common-args='-o StrictHostKeyChecking=no'"
    ]
  }

  tags = {
    environment = var.env
  }

}