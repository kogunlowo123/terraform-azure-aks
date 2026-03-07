provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-complete-example"
  location = "West US 2"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-complete"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "system" {
  name                 = "snet-aks-system"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_subnet" "user" {
  name                 = "snet-aks-user"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.4.0/22"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_container_registry" "example" {
  name                = "akscompleteacr"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"
}

module "aks" {
  source = "../../"

  cluster_name        = "aks-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kubernetes_version  = "1.29"
  dns_prefix          = "akscomplete"
  vnet_subnet_id      = azurerm_subnet.system.id

  private_cluster_enabled = true
  sku_tier                = "Premium"

  default_node_pool = {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    node_count                   = 3
    min_count                    = 3
    max_count                    = 5
    os_disk_size_gb              = 128
    os_disk_type                 = "Ephemeral"
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
  }

  additional_node_pools = {
    general = {
      vm_size         = "Standard_D8s_v5"
      min_count       = 3
      max_count       = 20
      os_disk_size_gb = 256
      os_disk_type    = "Ephemeral"
      max_pods        = 110
      vnet_subnet_id  = azurerm_subnet.user.id
      node_labels     = { "workload-type" = "general" }
    }
    compute = {
      vm_size         = "Standard_F16s_v2"
      min_count       = 0
      max_count       = 50
      os_disk_size_gb = 128
      os_disk_type    = "Ephemeral"
      vnet_subnet_id  = azurerm_subnet.user.id
      node_labels     = { "workload-type" = "compute" }
      node_taints     = ["dedicated=compute:NoSchedule"]
    }
    memory = {
      vm_size         = "Standard_E16s_v5"
      min_count       = 0
      max_count       = 20
      os_disk_size_gb = 128
      vnet_subnet_id  = azurerm_subnet.user.id
      node_labels     = { "workload-type" = "memory" }
      node_taints     = ["dedicated=memory:NoSchedule"]
    }
  }

  enable_workload_identity          = true
  enable_oidc_issuer                = true
  enable_defender                   = true
  enable_policy                     = true
  enable_key_vault_secrets_provider = true
  enable_image_cleaner              = true
  enable_blob_driver                = true

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  acr_id                     = azurerm_container_registry.example.id

  azure_ad_admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]
  authorized_ip_ranges            = ["203.0.113.0/24"]

  maintenance_window = {
    allowed = [
      {
        day   = "Sunday"
        hours = [0, 1, 2, 3, 4, 5]
      }
    ]
    not_allowed = [
      {
        start = "2026-12-20T00:00:00Z"
        end   = "2027-01-05T00:00:00Z"
      }
    ]
  }

  tags = {
    Environment = "production"
    Example     = "complete"
    CostCenter  = "engineering"
  }
}

output "cluster_id" {
  value = module.aks.cluster_id
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "kubelet_identity" {
  value = module.aks.kubelet_identity
}
