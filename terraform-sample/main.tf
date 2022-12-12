terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "=2.91.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "sac_group" {
  name     = "sac-test-resources"
  location = "East US"
}

# Creating vnet
resource "azurerm_virtual_network" "sac_vnet" {
  name                = "sac-vnet0"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.sac_group.location
  resource_group_name = azurerm_resource_group.sac_group.name
}

# Creating subnet
resource "azurerm_subnet" "sac_subnet" {
  name                 = "sac-subnet0"
  resource_group_name  = azurerm_resource_group.sac_group.name
  virtual_network_name = azurerm_virtual_network.sac_vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

# Create the loadbalancer resource
resource "azurerm_lb" "sac_example" {
  name                = "SaCTestLoadBalancer"
  location            = "East US"
  resource_group_name = azurerm_resource_group.sac_group.name

  frontend_ip_configuration {
    name                 = ""
    subnet_id = azurerm_subnet.sac_subnet.id
    private_ip_address = "10.1.0.12"
    private_ip_address_allocation = "Static"
    private_ip_address_version = "IPv4"
    zones = ["1"]
  }

  tags = {
    "env" = "prod"
  }
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PrivateIPAddress2"
    subnet_id = azurerm_subnet.sac_subnet.id
    private_ip_address = "10.1.0.14"
    private_ip_address_allocation = "Static"
    private_ip_address_version = "IPv6"
    zones = ["2"]
  }
}

resource "azurerm_lb" "sac_example_lb_example2" {
  name                = "SaCTestLoadBalancer"
  location            = "East US"
  resource_group_name = azurerm_resource_group.sac_group.name

  frontend_ip_configuration {
    name                 = ""
    subnet_id = azurerm_subnet.sac_subnet.id
    private_ip_address = "10.1.0.12"
    private_ip_address_allocation = "Static"
    private_ip_address_version = "IPv4"
    zones = ["1"]
  }

  tags = {
    "env" = "prod"
  }
  sku = "Standard"

  frontend_ip_configuration {
    name                 = ""
    subnet_id = azurerm_subnet.sac_subnet.id
    private_ip_address = "10.1.0.14"
    private_ip_address_allocation = "Static"
    private_ip_address_version = "IPv6"
    zones = ["2"]
  }
}

# Creating inbound NAT rule 0
resource "azurerm_lb_nat_rule" "nat_rule_0" {
  resource_group_name            = azurerm_resource_group.sac_group.name
  loadbalancer_id                = azurerm_lb.sac_example.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PrivateIPAddress"
}

resource "azurerm_lb_nat_rule" "nat_rule_32" {
  resource_group_name            = azurerm_resource_group.sac_group.name
  loadbalancer_id                = azurerm_lb.sac_example_lb_example2.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PrivateIPAddress2"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
}

resource "azurerm_key_vault" "example" {
  name                        = "examplekeyvault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

# Creating inbound NAT rule 1
resource "azurerm_lb_nat_rule" "nat_rule_1" {
  resource_group_name            = azurerm_resource_group.sac_group.name
  loadbalancer_id                = azurerm_lb.sac_example.id
  name                           = "SQLAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3306
  backend_port                   = 3306
  frontend_ip_configuration_name = "PrivateIPAddress"
}

# Creating backend address pool
resource "azurerm_lb_backend_address_pool" "backend_address_pool_0" {
  resource_group_name = azurerm_resource_group.sac_group.name
  loadbalancer_id     = azurerm_lb.sac_example.id
  name                = "be-0"
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool_1" {
  resource_group_name = azurerm_resource_group.sac_group.name
  loadbalancer_id     = azurerm_lb.sac_example.id
  name                = "be-1"
}
# creating backend address pool addresses
resource "azurerm_lb_backend_address_pool_address" "be_pool_0" {
  name                    = "be-pool-0-0"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_0.id
  virtual_network_id      = azurerm_virtual_network.sac_vnet.id 
  ip_address              = "10.0.0.6"
}

resource "azurerm_lb_backend_address_pool_address" "be_pool_1" {
  name                    = "be-pool-0-1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_0.id
  virtual_network_id      = azurerm_virtual_network.sac_vnet.id 
  ip_address              = "10.0.0.7"
}


resource "azurerm_lb_backend_address_pool_address" "be_pool_2" {
  name                    = "be-pool-1-0"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_1.id
  virtual_network_id      = azurerm_virtual_network.sac_vnet.id 
  ip_address              = "10.0.0.8"
}
# # Creating Outbound rule
resource "azurerm_lb_outbound_rule" "examob_rule_0ple" {
  resource_group_name     = azurerm_resource_group.sac_group.name
  loadbalancer_id         = azurerm_lb.sac_example.id
  name                    = "OutboundRule"
  protocol                = "All"
  # oak9: azurerm_lb_probe.protocol does not ensure encryption of data-in-transit
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_0.id

  frontend_ip_configuration {
    name = "PrivateIPAddress"
  }
}

# Creating LB rule 0
resource "azurerm_lb_rule" "lb_rule_0" {
  resource_group_name            = azurerm_resource_group.sac_group.name
  loadbalancer_id                = azurerm_lb.sac_example.id
  name                           = "LBRule0"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "PrivateIPAddress"
}

# Creating Probe 0
resource "azurerm_lb_probe" "probe_0" {
  resource_group_name = azurerm_resource_group.sac_group.name
  loadbalancer_id     = azurerm_lb.sac_example.id
  name                = "ssh-running-probe"
  port                = 22
}