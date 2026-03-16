resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.cluster_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled
  sku_tier                = var.sku_tier
  node_resource_group     = "${var.cluster_name}-nodes"

  workload_identity_enabled         = var.enable_workload_identity
  oidc_issuer_enabled               = var.enable_oidc_issuer
  azure_policy_enabled              = var.enable_policy
  image_cleaner_enabled             = var.enable_image_cleaner
  image_cleaner_interval_hours      = var.enable_image_cleaner ? 48 : null
  role_based_access_control_enabled = true

  tags = var.tags

  default_node_pool {
    name                         = var.default_node_pool.name
    vm_size                      = var.default_node_pool.vm_size
    node_count                   = var.default_node_pool.min_count != null && var.default_node_pool.max_count != null ? null : var.default_node_pool.node_count
    min_count                    = var.default_node_pool.min_count != null && var.default_node_pool.max_count != null ? var.default_node_pool.min_count : null
    max_count                    = var.default_node_pool.min_count != null && var.default_node_pool.max_count != null ? var.default_node_pool.max_count : null
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    zones                        = var.default_node_pool.zones
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    enable_auto_scaling          = var.default_node_pool.min_count != null && var.default_node_pool.max_count != null
    vnet_subnet_id               = var.vnet_subnet_id
    temporary_name_for_rotation  = "${var.default_node_pool.name}tmp"

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    network_dataplane   = var.network_dataplane
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    pod_cidr            = var.network_plugin_mode == "overlay" ? "10.244.0.0/16" : null
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = length(var.azure_ad_admin_group_object_ids) > 0 ? [1] : []
    content {
      managed                = true
      azure_rbac_enabled     = true
      admin_group_object_ids = var.azure_ad_admin_group_object_ids
    }
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.authorized_ip_ranges
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.enable_defender && var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "2m"
    }
  }

  storage_profile {
    blob_driver_enabled = var.enable_blob_driver
    disk_driver_enabled = true
    file_driver_enabled = true
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = {
    for k, v in var.additional_node_pools : k => merge(v, {
      vnet_subnet_id = coalesce(v.vnet_subnet_id, var.vnet_subnet_id)
    })
  }

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.min_count != null ? null : each.value.node_count
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  zones                 = each.value.zones
  mode                  = each.value.mode
  os_type               = each.value.os_type
  os_sku                = each.value.os_sku
  max_pods              = each.value.max_pods
  enable_auto_scaling   = each.value.min_count != null && each.value.max_count != null
  vnet_subnet_id        = each.value.vnet_subnet_id
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  tags = merge(var.tags, each.value.tags)

  upgrade_settings {
    max_surge = "33%"
  }

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.acr_id != null ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
