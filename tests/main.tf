resource "azurerm_resource_group" "test" {
  name     = "rg-aks-test"
  location = "eastus2"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet-aks-test"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "snet-aks-test"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.1.0.0/22"]
}

module "test" {
  source = "../"

  cluster_name        = "aks-test-cluster"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  kubernetes_version  = "1.29"
  dns_prefix          = "aks-test"
  vnet_subnet_id      = azurerm_subnet.test.id

  default_node_pool = {
    name    = "system"
    vm_size = "Standard_D4s_v5"
  }

  additional_node_pools = {
    workload = {
      vm_size = "Standard_D8s_v5"
    }
  }

  private_cluster_enabled          = true
  enable_workload_identity         = true
  enable_oidc_issuer               = true
  enable_defender                  = false
  enable_policy                    = false
  enable_key_vault_secrets_provider = true
  enable_image_cleaner             = true

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
