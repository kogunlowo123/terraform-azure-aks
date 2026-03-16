variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster."
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
  description = "SKU tier for the AKS cluster (Free, Standard, or Premium)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The sku_tier must be one of: Free, Standard, Premium."
  }
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the default node pool."
  type        = string
}

variable "network_plugin" {
  description = "Network plugin for networking (azure or none)."
  type        = string
  default     = "azure"
}

variable "network_plugin_mode" {
  description = "Network plugin mode (set to overlay for Azure CNI Overlay)."
  type        = string
  default     = "overlay"
}

variable "network_policy" {
  description = "Network policy to use (calico, azure, or cilium)."
  type        = string
  default     = "cilium"
}

variable "network_dataplane" {
  description = "Network dataplane to use (azure or cilium)."
  type        = string
  default     = "cilium"
}

variable "default_node_pool" {
  description = "Configuration for the default system node pool."
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
  description = "Map of additional user node pools to create."
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
  description = "Enable workload identity on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_policy" {
  description = "Enable Azure Policy for the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_key_vault_secrets_provider" {
  description = "Enable the Key Vault secrets provider add-on."
  type        = bool
  default     = true
}

variable "enable_image_cleaner" {
  description = "Enable the image cleaner on the AKS cluster."
  type        = bool
  default     = true
}

variable "enable_blob_driver" {
  description = "Enable the Blob CSI driver on the AKS cluster."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring."
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
  description = "Azure AD group object IDs with admin access to the cluster."
  type        = list(string)
  default     = []
}

variable "acr_id" {
  description = "Azure Container Registry ID for AcrPull access (null to skip)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
