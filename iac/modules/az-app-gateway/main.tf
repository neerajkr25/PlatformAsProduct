terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "publicFrontendIp"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "backendPool"
    fqdns = var.backend_fqdns
  }

  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "publicFrontendIp"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSettings"
  }

  tags = var.tags
}
