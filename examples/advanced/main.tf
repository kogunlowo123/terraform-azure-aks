provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-advanced-example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-advanced"
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

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-advanced"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_registry" "example" {
  name                = "acraksadvanced"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
}

module "aks" {
  source = "../../"

  cluster_name        = "aks-advanced-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kubernetes_version  = "1.29"
  dns_prefix          = "aksadv"
  vnet_subnet_id      = azurerm_subnet.example.id

  private_cluster_enabled = true
  sku_tier                = "Standard"

  default_node_pool = {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    min_count                    = 3
    max_count                    = 5
    os_disk_size_gb              = 128
    os_disk_type                 = "Managed"
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
  }

  additional_node_pools = {
    workload = {
      vm_size     = "Standard_D8s_v5"
      min_count   = 3
      max_count   = 10
      node_labels = { "workload-type" = "general" }
    }
    spot = {
      vm_size     = "Standard_D4s_v5"
      min_count   = 0
      max_count   = 10
      node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      node_labels = { "kubernetes.azure.com/scalesetpriority" = "spot" }
    }
  }

  enable_workload_identity         = true
  enable_oidc_issuer               = true
  enable_defender                  = true
  enable_policy                    = true
  enable_key_vault_secrets_provider = true
  enable_image_cleaner             = true

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  acr_id                     = azurerm_container_registry.example.id

  azure_ad_admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]

  maintenance_window = {
    allowed = [
      {
        day   = "Saturday"
        hours = [0, 1, 2, 3, 4]
      }
    ]
    not_allowed = []
  }

  tags = {
    Environment = "staging"
    Example     = "advanced"
  }
}

output "cluster_id" {
  value = module.aks.cluster_id
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}
