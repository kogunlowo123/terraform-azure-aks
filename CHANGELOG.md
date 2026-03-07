# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- Initial release of the terraform-azure-aks module.
- AKS cluster resource with system-assigned managed identity.
- Default (system) node pool with auto-scaling and availability zone support.
- Additional (user) node pools via configurable map variable.
- Azure CNI Overlay networking with Cilium network policy and dataplane.
- Private cluster support enabled by default.
- Workload identity and OIDC issuer support.
- Microsoft Defender for Containers integration.
- Azure Policy for Kubernetes integration.
- Key Vault secrets provider (CSI driver) with secret rotation.
- Image cleaner for stale container image cleanup.
- Blob CSI driver support (opt-in).
- OMS agent integration with Log Analytics workspace.
- Maintenance window configuration.
- API server authorized IP ranges.
- Azure AD RBAC integration with admin group support.
- ACR pull role assignment for seamless image pulls.
- Storage profile configuration (blob, disk, file drivers).
- Upgrade settings with max surge configuration.
- Basic, advanced, and complete usage examples.
- Comprehensive README with full input/output documentation.
