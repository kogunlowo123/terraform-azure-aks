# terraform-azure-aks

Production-grade Terraform module for deploying Azure Kubernetes Service (AKS) clusters with enterprise features including system/user node pools, workload identity, Azure CNI Overlay networking, Microsoft Defender, Azure Policy, and GitOps-ready configuration.

## Features

- **System and User Node Pools** -- Dedicated system node pool with `CriticalAddonsOnly` taint and configurable additional user node pools via a flexible map variable.
- **Azure CNI Overlay with Cilium** -- High-performance networking using Azure CNI Overlay with Cilium as both the network policy engine and dataplane.
- **Workload Identity** -- OIDC issuer and workload identity federation enabled by default for secure, passwordless access to Azure resources from pods.
- **Microsoft Defender for Containers** -- Runtime threat detection and vulnerability scanning integration.
- **Azure Policy for Kubernetes** -- Enforce organizational standards and compliance at scale using Azure Policy.
- **Key Vault Secrets Provider** -- CSI driver integration for mounting Azure Key Vault secrets directly into pods.
- **Image Cleaner** -- Automatic cleanup of stale container images on cluster nodes.
- **Private Cluster** -- API server is private by default, accessible only within the virtual network.
- **Availability Zones** -- Node pools span three availability zones by default for high availability.
- **Maintenance Windows** -- Configurable maintenance windows for planned cluster updates.
- **ACR Integration** -- Automatic `AcrPull` role assignment for seamless container image pulls.
- **Auto-scaling** -- Cluster autoscaler enabled on all node pools with configurable min/max counts.

## Usage

### Basic

```hcl
module "aks" {
  source = "github.com/kogunlowo123/terraform-azure-aks"

  cluster_name        = "my-aks-cluster"
  resource_group_name = "rg-aks"
  location            = "East US"
  kubernetes_version  = "1.29"
  dns_prefix          = "myaks"
  vnet_subnet_id      = azurerm_subnet.aks.id

  default_node_pool = {
    name      = "system"
    vm_size   = "Standard_D4s_v5"
    min_count = 3
    max_count = 5
  }

  tags = {
    Environment = "production"
  }
}
```

### With Additional Node Pools

```hcl
module "aks" {
  source = "github.com/kogunlowo123/terraform-azure-aks"

  cluster_name        = "my-aks-cluster"
  resource_group_name = "rg-aks"
  location            = "East US"
  kubernetes_version  = "1.29"
  dns_prefix          = "myaks"
  vnet_subnet_id      = azurerm_subnet.aks.id

  default_node_pool = {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    min_count                    = 3
    max_count                    = 5
    only_critical_addons_enabled = true
  }

  additional_node_pools = {
    workload = {
      vm_size     = "Standard_D8s_v5"
      min_count   = 3
      max_count   = 20
      node_labels = { "workload-type" = "general" }
    }
    compute = {
      vm_size     = "Standard_F16s_v2"
      min_count   = 0
      max_count   = 50
      node_labels = { "workload-type" = "compute" }
      node_taints = ["dedicated=compute:NoSchedule"]
    }
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  acr_id                     = azurerm_container_registry.this.id

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | The name of the AKS cluster | `string` | n/a | yes |
| resource_group_name | The resource group name | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| kubernetes_version | The Kubernetes version | `string` | n/a | yes |
| dns_prefix | DNS prefix for the cluster | `string` | n/a | yes |
| vnet_subnet_id | Subnet ID for the default node pool | `string` | n/a | yes |
| private_cluster_enabled | Enable private cluster | `bool` | `true` | no |
| sku_tier | SKU tier (Free, Standard, Premium) | `string` | `"Standard"` | no |
| network_plugin | Network plugin (azure, none) | `string` | `"azure"` | no |
| network_plugin_mode | Network plugin mode | `string` | `"overlay"` | no |
| network_policy | Network policy (calico, azure, cilium) | `string` | `"cilium"` | no |
| network_dataplane | Network dataplane (azure, cilium) | `string` | `"cilium"` | no |
| default_node_pool | Default (system) node pool config | `object` | n/a | yes |
| additional_node_pools | Map of additional node pools | `map(object)` | `{}` | no |
| enable_workload_identity | Enable workload identity | `bool` | `true` | no |
| enable_oidc_issuer | Enable OIDC issuer | `bool` | `true` | no |
| enable_defender | Enable Microsoft Defender | `bool` | `true` | no |
| enable_policy | Enable Azure Policy | `bool` | `true` | no |
| enable_key_vault_secrets_provider | Enable Key Vault CSI driver | `bool` | `true` | no |
| enable_image_cleaner | Enable image cleaner | `bool` | `true` | no |
| enable_blob_driver | Enable Blob CSI driver | `bool` | `false` | no |
| log_analytics_workspace_id | Log Analytics workspace ID | `string` | `null` | no |
| maintenance_window | Maintenance window config | `object` | `null` | no |
| authorized_ip_ranges | Authorized IP ranges for API server | `list(string)` | `[]` | no |
| azure_ad_admin_group_object_ids | Azure AD admin group IDs | `list(string)` | `[]` | no |
| acr_id | Azure Container Registry ID for AcrPull | `string` | `null` | no |
| tags | Tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the AKS cluster |
| cluster_fqdn | The FQDN of the AKS cluster |
| cluster_private_fqdn | The private FQDN of the AKS cluster |
| kube_config | The raw kubeconfig (sensitive) |
| oidc_issuer_url | The OIDC issuer URL for workload identity |
| node_resource_group | The node resource group name |
| kubelet_identity | The kubelet managed identity |
| cluster_identity | The cluster system-assigned identity |
| key_vault_secrets_provider_identity | The Key Vault secrets provider identity |

## Examples

- [Basic](./examples/basic/) -- Minimal AKS cluster with a single node pool.
- [Advanced](./examples/advanced/) -- AKS cluster with multiple node pools, Defender, monitoring, and ACR integration.
- [Complete](./examples/complete/) -- Full production setup with all features enabled.

## License

MIT License. See [LICENSE](./LICENSE) for details.
