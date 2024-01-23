terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    ansible = {
        source = "nbering/ansible"
        version = "1.0.4"
    }
  }
  backend "azurerm" {
      resource_group_name  = "backend"
      storage_account_name = "backendthni7"
      container_name       = "backend"
      key                  = "templates/integration/basic.tfstate"
  }



}


provider "azurerm" {
  use_oidc = true
  features {}
}
resource "azurerm_resource_group" "state-demo-secure" {
  name     = "state-demo"
  location = "UK South"
}
data  "external" "git_origin" {
  program = [ "bash", "-c", "echo \"{ \\\"Origin\\\": \\\"$(git config --get remote.origin.url)\\\"}\"" ]
}
locals {
  default_tags = {
      GitRepo = replace(replace(data.external.git_origin.result.Origin, "/(http.*@)/", ""), "%20", " ")
  }
}
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.state-demo-secure.name
  location            = azurerm_resource_group.state-demo-secure.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.ec2.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = local.default_tags
}

resource "ansible_host" "instance_name" {
  inventory_hostname = "demo"
  groups = ["instances"]
  vars = {
    ansible_host = azurerm_linux_virtual_machine.example.public_ip_address
    ansible_ssh_user = "adminuser"
    # ansible_ssh_private_key_file
    # ansible_password = rsadecrypt(aws_instance.AWSORAD02.password_data, tls_private_key.ec2.private_key_pem)
    ansible_port = 22
    ansible_connection = "ssh"
    # ansible_winrm_server_cert_validation = "ignore"
    ansible_host_key_checking = "False"
    # custom vars
    # vol_binaries_blah = aws_ebs_volume.binaries.id
  }
}