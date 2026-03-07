variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the AKS cluster will be deployed."
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Whether the AKS cluster API server should be private."
  type        = bool
  default     = true
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster. Possible values are Free, Standard, and Premium."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The sku_tier must be one of: Free, Standard, Premium."
  }
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet where the default node pool will be placed."
  type        = string
}

variable "network_plugin" {
  description = "The network plugin to use for networking. Possible values are azure and none."
  type        = string
  default     = "azure"
}

variable "network_plugin_mode" {
  description = "The network plugin mode. Set to overlay for Azure CNI Overlay."
  type        = string
  default     = "overlay"
}

variable "network_policy" {
  description = "The network policy to use. Possible values are calico, azure, and cilium."
  type        = string
  default     = "cilium"
}

variable "network_dataplane" {
  description = "The network dataplane to use. Possible values are azure and cilium."
  type        = string
  default     = "cilium"
}

variable "default_node_pool" {
  description = "Configuration for the default (system) node pool."
  type = object({
    name                         = string
    vm_size                      = string
    node_count                   = optional(number, 3)
    min_count                    = optional(number, 3)
    max_count                    = optional(number, 5)
    os_disk_size_gb              = optional(number, 128)
    os_disk_type                 = optional(string, "Managed")
    zones                        = optional(list(string), ["1", "2", "3"])
    only_critical_addons_enabled = optional(bool, true)
  })
}

variable "additional_node_pools" {
  description = "A map of additional (user) node pools to create."
  type = map(object({
    vm_size         = string
    node_count      = optional(number, 3)
    min_count       = optional(number, 3)
    max_count       = optional(number, 5)
    os_disk_size_gb = optional(number, 128)
    os_disk_type    = optional(string, "Managed")
    zones           = optional(list(string), ["1", "2", "3"])
    mode            = optional(string, "User")
    os_type         = optional(string, "Linux")
    os_sku          = optional(string, "Ubuntu")
    max_pods        = optional(number, 110)
    node_labels     = optional(map(string), {})
    node_taints     = optional(list(string), [])
    vnet_subnet_id  = optional(string)
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "enable_workload_identity" {
  description = "Whether to enable workload identity on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Whether to enable OIDC issuer on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Whether to enable Microsoft Defender for the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_policy" {
  description = "Whether to enable Azure Policy for the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_key_vault_secrets_provider" {
  description = "Whether to enable the Key Vault secrets provider add-on."
  type        = bool
  default     = true
}

variable "enable_image_cleaner" {
  description = "Whether to enable the image cleaner on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_blob_driver" {
  description = "Whether to enable the Blob CSI driver on the AKS cluster."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for monitoring."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Maintenance window configuration for the AKS cluster."
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })), [])
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

variable "authorized_ip_ranges" {
  description = "List of authorized IP ranges for the API server."
  type        = list(string)
  default     = []
}

variable "azure_ad_admin_group_object_ids" {
  description = "List of Azure AD group object IDs that will have admin access to the cluster."
  type        = list(string)
  default     = []
}

variable "acr_id" {
  description = "The ID of the Azure Container Registry to grant AcrPull access. Set to null to skip."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
