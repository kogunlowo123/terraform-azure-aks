locals {
  cluster_name = var.cluster_name

  default_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-aks"
  })

  # Determine if auto-scaling is enabled based on min/max count
  enable_auto_scaling = var.default_node_pool.min_count != null && var.default_node_pool.max_count != null

  # Use the provided vnet_subnet_id for additional node pools, falling back to the default
  additional_node_pools = {
    for k, v in var.additional_node_pools : k => merge(v, {
      vnet_subnet_id = coalesce(v.vnet_subnet_id, var.vnet_subnet_id)
    })
  }
}
