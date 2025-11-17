
resource "azurerm_public_ip" "this" {
  name                = var.bastion_host_public_ip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = var.resource_group_name
  copy_paste_enabled = true
  file_copy_enabled = true
  sku = "Standard"
  ip_connect_enabled = var.ip_connect_enabled
  ip_configuration {
    name                 = var.ip_config_name
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
  tags = var.tags
}