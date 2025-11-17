# Optional Public IP (only created when requested)
resource "azurerm_public_ip" "this" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Optional NSG (only if public IP enabled)
resource "azurerm_network_security_group" "this" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.vm_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Outbound-HTTPS"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network interface
resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# Attach NSG to NIC conditionally (association resource)
resource "azurerm_network_interface_security_group_association" "assoc" {
  count                     = var.create_public_ip ? 1 : 0
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this[0].id
}

# cloud-init script (to install the packages in the VM)
# locals {
#   cloud_init = trimspace(<<-EOF
#               #cloud-config
#               package_update: true
#               package_upgrade: true
#               packages:
#                 - ca-certificates
#                 - curl
#                 - apt-transport-https
#                 - gnupg
#                 - lsb-release
#                 - jq
#               runcmd:
#                 - curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/ms.gpg
#                 - echo "deb [signed-by=/usr/share/keyrings/ms.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list
#                 - apt-get update
#                 - DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli
#                 - curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#                 - install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#                 - curl -fsSL https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz -o helm.tar.gz && tar -xzvf helm.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && rm -rf linux-amd64 helm.tar.gz
#                 - mkdir -p /home/${var.admin_username}/.ssh
#                 - echo "${var.admin_ssh_public_key}" >> /home/${var.admin_username}/.ssh/authorized_keys
#                 - chown -R ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/.ssh
#                 - chmod 700 /home/${var.admin_username}/.ssh
#                 - chmod 600 /home/${var.admin_username}/.ssh/authorized_keys
# ${join("\n", [for c in var.extra_cloudinit_commands : "                - ${c}"])}
#               EOF
#   )
# }

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = var.os_image_publisher
    offer     = var.os_image_offer
    sku       = var.os_image_sku
    version   = var.os_image_version
  }

  # custom_data = base64encode(local.cloud_init)

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Purpose = "vm"
    Env     = ""
  }

  depends_on = [
    azurerm_network_interface.this
  ]
}

# # Optional: grant the VM's managed identity a role on the AKS resource so the VM can run:
# # az login --identity
# # az aks get-credentials --admin ...
# resource "azurerm_role_assignment" "vm_to_aks" {
#   count = var.aks_resource_id != "" ? 1 : 0

#   scope                = var.aks_resource_id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = azurerm_linux_virtual_machine.this.identity[0].principal_id
# }
