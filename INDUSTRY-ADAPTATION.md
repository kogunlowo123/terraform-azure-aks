# Industry Adaptation Guide

## Overview
The `terraform-azure-aks` module provisions a production-grade Azure Kubernetes Service cluster with private endpoints, Cilium network policies, Microsoft Defender, Azure Policy, Key Vault secrets provider, workload identity, OIDC issuer, multiple node pools, maintenance windows, and ACR integration. Its security-first defaults make it adaptable to highly regulated industries.

## Healthcare
### Compliance Requirements
- HIPAA, HITRUST, HL7 FHIR
### Configuration Changes
- Set `private_cluster_enabled = true` to ensure the API server is not internet-accessible (HIPAA access controls).
- Set `sku_tier = "Premium"` for SLA-backed uptime guarantees required for clinical systems.
- Set `enable_defender = true` with `log_analytics_workspace_id` for runtime threat detection on healthcare workloads.
- Set `enable_policy = true` to enforce Azure Policy for AKS (e.g., no privileged containers, required labels).
- Set `enable_key_vault_secrets_provider = true` to pull PHI encryption keys and certificates from Key Vault without embedding secrets in pods.
- Set `enable_workload_identity = true` and `enable_oidc_issuer = true` for passwordless, identity-based access to Azure services.
- Configure `network_policy = "cilium"` for microsegmentation of clinical vs. administrative namespaces.
- Use `additional_node_pools` with `node_taints` to isolate PHI-processing workloads (e.g., `workload=phi:NoSchedule`).
- Set `azure_ad_admin_group_object_ids` to restrict cluster admin access to authorized healthcare IT groups.
### Example Use Case
A telehealth platform runs FHIR APIs on AKS with a private cluster, Defender-enabled monitoring, Cilium network policies separating patient-facing and analytics namespaces, and Key Vault secrets provider managing TLS certificates and database credentials.

## Finance
### Compliance Requirements
- SOX, PCI-DSS, SOC 2
### Configuration Changes
- Set `private_cluster_enabled = true` and configure `authorized_ip_ranges` for management access from known corporate IPs only.
- Set `enable_defender = true` for container-level vulnerability scanning and runtime threat detection (PCI-DSS Requirement 6).
- Set `enable_policy = true` to enforce PCI-relevant policies (e.g., deny containers running as root, enforce resource limits).
- Configure `default_node_pool` with `zones = ["1", "2", "3"]` for multi-AZ availability.
- Use `additional_node_pools` with `node_labels = { "pci-scope" = "in-scope" }` and `node_taints` to isolate CDE workloads.
- Set `enable_key_vault_secrets_provider = true` for PCI-DSS Requirement 3 (protect stored cardholder data keys).
- Set `network_policy = "cilium"` and `network_dataplane = "cilium"` for L7 network policy enforcement.
### Example Use Case
A payment processor deploys its transaction services on AKS with PCI-scoped node pools isolated via taints, Defender scanning container images, Cilium enforcing L7 policies between payment and non-payment services, and Key Vault managing encryption keys.

## Government
### Compliance Requirements
- FedRAMP, CMMC, NIST 800-53
### Configuration Changes
- Deploy in Azure Government regions via `location`.
- Set `private_cluster_enabled = true` and `sku_tier = "Premium"` (NIST AC-17, SC-7).
- Set `enable_defender = true` for continuous monitoring (NIST SI-4).
- Set `enable_policy = true` to enforce NIST baseline policies via Azure Policy for AKS.
- Set `enable_workload_identity = true` for strong authentication (NIST IA-2).
- Configure `azure_ad_admin_group_object_ids` with CAC/PIV-authenticated Azure AD groups (NIST IA-5).
- Set `maintenance_window` to government-approved maintenance periods.
- Use `additional_node_pools` with `os_sku = "Ubuntu"` and `os_disk_type = "Managed"` for STIG-hardened configurations.
### Example Use Case
A federal agency runs its IL-5 workloads on AKS in Azure Government with private endpoints, Defender monitoring, Azure Policy enforcing NIST baselines, and Azure AD RBAC restricting access to PIV-authenticated administrators.

## Retail / E-Commerce
### Compliance Requirements
- PCI-DSS, CCPA/GDPR
### Configuration Changes
- Configure `default_node_pool` with `min_count = 3` and `max_count = 20` for auto-scaling during peak traffic.
- Create `additional_node_pools` with `mode = "User"` for application workloads and configure `max_count` for burst capacity.
- Set `enable_image_cleaner = true` to remove unused container images and reduce attack surface.
- Set `enable_blob_driver = true` for large media asset storage (product images, videos).
- Set `enable_key_vault_secrets_provider = true` for payment gateway API keys and certificates.
- Set `acr_id` to grant AcrPull access for private container image deployment.
- Configure `network_policy = "cilium"` to segment payment services from catalog and search services.
### Example Use Case
An e-commerce company deploys its storefront on AKS with auto-scaling node pools handling Black Friday traffic, Blob CSI driver serving product assets, Cilium policies isolating the checkout service, and ACR integration for private image deployment.

## Education
### Compliance Requirements
- FERPA, COPPA
### Configuration Changes
- Set `private_cluster_enabled = true` to protect student data environments.
- Set `enable_defender = true` with `log_analytics_workspace_id` for monitoring access to student data.
- Set `enable_workload_identity = true` for secure, passwordless access to Azure SQL and Blob Storage housing student records.
- Configure `azure_ad_admin_group_object_ids` with education IT staff groups.
- Use `additional_node_pools` with labels to separate student-facing applications from administrative workloads.
- Set `enable_policy = true` to enforce namespace-level resource quotas and security policies.
### Example Use Case
A university runs its learning management system and student portal on AKS with private endpoints, Azure AD RBAC for faculty vs. IT admin access, workload identity for database connections, and Defender monitoring for anomalous access patterns.

## SaaS / Multi-Tenant
### Compliance Requirements
- SOC 2, ISO 27001
### Configuration Changes
- Set `sku_tier = "Standard"` or `"Premium"` for SLA-backed uptime for tenant workloads.
- Create per-tenant-tier `additional_node_pools` with `node_labels` (e.g., `tenant-tier: enterprise`) and `node_taints` for workload isolation.
- Set `enable_workload_identity = true` and `enable_oidc_issuer = true` so each tenant's pods authenticate independently to Azure services.
- Set `enable_key_vault_secrets_provider = true` for tenant-specific secret injection.
- Set `enable_defender = true` for SOC 2 security monitoring evidence.
- Configure `network_policy = "cilium"` with `network_dataplane = "cilium"` for namespace-level tenant isolation.
- Set `acr_id` for centralized private container image management.
### Example Use Case
A B2B SaaS company hosts 100+ tenants on AKS with namespace-per-tenant isolation, Cilium L7 policies preventing cross-tenant traffic, dedicated node pools for enterprise-tier tenants, and workload identity mapping each tenant to isolated Azure resources.

## Cross-Industry Best Practices
- Use environment-based configuration by parameterizing `cluster_name`, `dns_prefix`, and `tags` per environment.
- Always enable encryption in transit via `private_cluster_enabled = true` and network policies.
- Enable audit logging and monitoring by setting `log_analytics_workspace_id`, `enable_defender = true`, and `enable_policy = true`.
- Enforce least-privilege access controls via `azure_ad_admin_group_object_ids`, workload identity, and RBAC.
- Implement network segmentation using Cilium network policies (`network_policy = "cilium"`) and node pool taints.
- Configure backup and disaster recovery by deploying across three `zones` with appropriate `sku_tier` for SLA guarantees.
