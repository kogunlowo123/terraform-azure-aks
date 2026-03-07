output "cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster when private cluster is enabled."
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "kube_config" {
  description = "The raw kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "node_resource_group" {
  description = "The name of the resource group containing the AKS node pool resources."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity" {
  description = "The kubelet managed identity assigned to the AKS cluster."
  value = {
    client_id                 = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.this.kubelet_identity[0].user_assigned_identity_id
  }
}

output "cluster_identity" {
  description = "The system-assigned managed identity of the AKS cluster."
  value = {
    principal_id = azurerm_kubernetes_cluster.this.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.this.identity[0].tenant_id
  }
}

output "key_vault_secrets_provider_identity" {
  description = "The identity of the Key Vault secrets provider."
  value       = var.enable_key_vault_secrets_provider ? azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0] : null
}
