provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-basic-example"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-basic"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.0.0/22"]
}

module "aks" {
  source = "../../"

  cluster_name        = "aks-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kubernetes_version  = "1.29"
  dns_prefix          = "aksbasic"
  vnet_subnet_id      = azurerm_subnet.example.id

  private_cluster_enabled = false
  enable_defender         = false
  enable_policy           = false

  default_node_pool = {
    name      = "system"
    vm_size   = "Standard_D4s_v5"
    min_count = 1
    max_count = 3
  }

  tags = {
    Environment = "dev"
    Example     = "basic"
  }
}

output "cluster_id" {
  value = module.aks.cluster_id
}
