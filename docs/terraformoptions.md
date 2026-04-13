# Terraform Options

Configuration Terraform Options:

1. [General](#general)
2. [Identity and Access Management](#identity-and-access-management)
3. [Network](#network)
4. [Cluster](#cluster)
5. [Cluster Add-ons](#cluster-add-ons)
6. [Workers](#workers)
7. [Bastion](#bastion)
8. [Operator](#operator)
9. [Extensions](#extensions)
   - [Cilium](#cilium)
   - [Multus](#multus)
   - [SR-IOV Device Plugin](#sr-iov-device-plugin)
   - [SR-IOV CNI Plugin](#sr-iov-cni-plugin)
   - [RDMA CNI Plugin](#rdma-cni-plugin)
   - [Whereabouts](#whereabouts)
   - [Metrics Server](#metrics-server)
   - [Cluster Autoscaler](#cluster-autoscaler)
   - [Prometheus](#prometheus)
   - [DCGM Exporter](#dcgm-exporter)
   - [Gatekeeper](#gatekeeper)
   - [MPI Operator](#mpi-operator)
   - [ArgoCD](#argocd)
   - [Service Accounts](#service-accounts)
10. [Utilities](#utilities)
11. [Tagging](#tagging)
12. [Validation Rules](#validation-rules)

## General

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `state_id` | Optional Terraform state_id from an existing deployment for resource reuse. | string | `null` |
| `output_detail` | Whether to include detailed output in the Terraform state. | `true` / `false` | `false` |
| `timezone` | Preferred timezone for worker, operator, and bastion instances. | string (IANA timezone) | `"Etc/UTC"` |
| `ssh_private_key` | SSH private key contents, optionally base64-encoded. Sensitive. | string | `null` |
| `ssh_private_key_path` | Path to SSH private key on the machine running Terraform. | string | `null` |
| `ssh_public_key` | SSH public key contents, optionally base64-encoded. | string | `null` |
| `ssh_public_key_path` | Path to SSH public key. | string | `null` |

## Identity and Access Management

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `tenancy_id` | Tenancy OCID. Required unless using `config_file_profile` or Resource Manager. | OCID string | `null` |
| `tenancy_ocid` | Tenancy OCID for Resource Manager. Used as alias for `tenancy_id` in RMS. | OCID string | `null` |
| `user_id` | User OCID for API key authentication. | OCID string | `null` |
| `current_user_ocid` | User OCID for Resource Manager. | OCID string | `null` |
| `compartment_id` | Compartment OCID where resources are created. Required. | OCID string | `null` |
| `compartment_ocid` | Compartment OCID for Resource Manager. | OCID string | `null` |
| `worker_compartment_id` | Compartment for worker resources. Defaults to `compartment_id`. | OCID string | `null` |
| `network_compartment_id` | Compartment for network resources. Defaults to `compartment_id`. | OCID string | `null` |
| `region` | OCI region for resource provisioning. | [OCI region identifier](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm) | `"us-ashburn-1"` |
| `home_region` | Tenancy home region. Required when `create_iam_resources = true`. | OCI region identifier | `null` |
| `api_fingerprint` | Fingerprint of the OCI API public key. | string | `null` |
| `api_private_key` | OCI API private key contents. Sensitive. | string | `null` |
| `api_private_key_password` | Password for the OCI API private key. Sensitive. | string | `null` |
| `api_private_key_path` | Path to the OCI API private key file. | string | `null` |
| `config_file_profile` | OCI CLI config file profile name for authentication. | string | `"DEFAULT"` |
| `create_iam_resources` | Whether to create IAM dynamic groups and policies. | `true` / `false` | `false` |
| `create_iam_autoscaler_policy` | Create IAM policy for cluster autoscaler. | `"never"` / `"auto"` / `"always"` | `"auto"` |
| `create_iam_kms_policy` | Create IAM policy for KMS encryption. | `"never"` / `"auto"` / `"always"` | `"auto"` |
| `create_iam_operator_policy` | Create IAM policy for operator instance principal. | `"never"` / `"auto"` / `"always"` | `"auto"` |
| `create_iam_worker_policy` | Create IAM policy for worker nodes. | `"never"` / `"auto"` / `"always"` | `"auto"` |
| `create_iam_tag_namespace` | Create IAM tag namespace and tags. | `true` / `false` | `false` |
| `create_iam_defined_tags` | Create IAM defined tags in the tag namespace. | `true` / `false` | `false` |
| `use_defined_tags` | Apply defined tags to created resources. | `true` / `false` | `false` |
| `tag_namespace` | Tag namespace name for OKE defined tags. | string | `"oke"` |

## Network

Relevant diagrams:
- [Network layout](./diagrams.md#network-layout)
- [Load balancer layout](./diagrams.md#load-balancer-layout)
- [Bastion access layout](./diagrams.md#bastion-access-layout)

### VCN

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_vcn` | Whether to create a VCN. Set to `false` to use an existing VCN. | `true` / `false` | `true` |
| `vcn_name` | Display name for the VCN. | string | `null` |
| `vcn_id` | OCID of an existing VCN. Required when `create_vcn = false`. | OCID string | `null` |
| `vcn_cidrs` | IPv4 CIDR blocks for the VCN. | list(string) | `["10.0.0.0/16"]` |
| `vcn_dns_label` | DNS label for the VCN. | string | `null` |
| `vcn_enable_ipv6_gua` | Enable IPv6 Global Unicast Address. | `true` / `false` | `true` |
| `vcn_ipv6_ula_cidrs` | IPv6 ULA CIDR blocks for the VCN. | list(string) | `[]` |
| `assign_dns` | Whether to assign DNS records to created instances and subnet hostname labels. | `true` / `false` | `true` |
| `lockdown_default_seclist` | Remove all default rules from the VCN default security list. | `true` / `false` | `true` |

### Gateways

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `vcn_create_internet_gateway` | Create an internet gateway. | `"auto"` / `"always"` / `"never"` | `"auto"` |
| `vcn_create_nat_gateway` | Create a NAT gateway. | `"auto"` / `"always"` / `"never"` | `"auto"` |
| `vcn_create_service_gateway` | Create a service gateway. | `"auto"` / `"always"` / `"never"` | `"always"` |
| `internet_gateway_id` | OCID of an existing internet gateway. | OCID string | `null` |
| `nat_gateway_id` | OCID of an existing NAT gateway. | OCID string | `null` |
| `nat_gateway_public_ip_id` | Reserved public IP OCID for the NAT gateway. | OCID string | `null` |

### Routing

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `ig_route_table_id` | OCID of an existing internet gateway route table. | OCID string | `null` |
| `nat_route_table_id` | OCID of an existing NAT gateway route table. | OCID string | `null` |
| `igw_ngw_mixed_route_id` | OCID of a mixed route table (NAT GW for IPv4, IGW for IPv6). | OCID string | `null` |
| `internet_gateway_route_rules` | Additional route rules for the internet gateway route table. | list(map(string)) | `null` |
| `nat_gateway_route_rules` | Additional route rules for the NAT gateway route table. | list(map(string)) | `null` |

### DRG

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_drg` | Whether to create a Dynamic Routing Gateway. | `true` / `false` | `false` |
| `drg_display_name` | Display name for the DRG. | string | `null` |
| `drg_id` | OCID of an existing DRG. | OCID string | `null` |
| `drg_compartment_id` | Compartment for the DRG. Defaults to `network_compartment_id`. | OCID string | `null` |
| `drg_attachments` | DRG attachment configurations. | map(any) | `{}` |
| `remote_peering_connections` | Remote peering connection configurations. | map(any) | `{}` |
| `local_peering_gateways` | Local peering gateway configurations. | map(any) | `null` |

### Subnets

See [Network layout](./diagrams.md#network-layout) for the default subnet split used by the module.

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `subnets` | Configuration for standard subnets (bastion, operator, cp, int_lb, pub_lb, workers, pods). Each entry supports `create`, `id`, `cidr`, `netnum`, `newbits`, `display_name`, `dns_label`, and `ipv6_cidr`. | map(object) | Module-defined defaults for all standard subnets |

Example with automatic subnet creation:

```hcl
subnets = {
  bastion  = { newbits = 13 }
  operator = { newbits = 13 }
  cp       = { newbits = 13 }
  int_lb   = { newbits = 11 }
  pub_lb   = { newbits = 11 }
  workers  = { newbits = 4 }
  pods     = { newbits = 2 }
}
```

Example with explicit CIDRs:

```hcl
subnets = {
  bastion  = { cidr = "10.0.0.0/29" }
  operator = { cidr = "10.0.0.64/29" }
  cp       = { cidr = "10.0.0.8/29" }
  int_lb   = { cidr = "10.0.0.32/27" }
  pub_lb   = { cidr = "10.0.128.0/27" }
  workers  = { cidr = "10.0.144.0/20" }
  pods     = { cidr = "10.0.64.0/18" }
}
```

Example with existing subnets:

```hcl
subnets = {
  operator = { id = "ocid1.subnet..." }
  cp       = { id = "ocid1.subnet..." }
  workers  = { id = "ocid1.subnet..." }
}
```

### Network Security Groups

See [Network layout](./diagrams.md#network-layout) for how the NSG-backed subnet boundaries fit together.

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `nsgs` | Configuration for NSGs (bastion, operator, cp, int_lb, pub_lb, workers, pods, optional `fss`). Each entry supports `create` and `id`. | map(object) | Module-defined defaults for standard NSGs |
| `allow_node_port_access` | Allow NodePort access to load balancers. | `true` / `false` | `false` |
| `allow_worker_internet_access` | Allow worker nodes outbound internet access. | `true` / `false` | `true` |
| `allow_pod_internet_access` | Allow pod outbound internet access. | `true` / `false` | `true` |
| `allow_worker_ssh_access` | Allow SSH access to worker nodes. | `true` / `false` | `false` |
| `allow_bastion_cluster_access` | Allow bastion to cluster endpoint access. | `true` / `false` | `false` |
| `allow_rules_cp` | Additional NSG rules for the control plane. | map(any) | `{}` |
| `allow_rules_internal_lb` | Additional NSG rules for internal load balancers. | map(any) | `{}` |
| `allow_rules_pods` | Additional NSG rules for pods. | map(any) | `{}` |
| `allow_rules_public_lb` | Additional NSG rules for public load balancers. | map(any) | `{}` |
| `allow_rules_workers` | Additional NSG rules for workers. | map(any) | `{}` |
| `control_plane_allowed_cidrs` | CIDR blocks allowed to access the control plane. | list(string) | `[]` |
| `enable_waf` | Enable WAF monitoring for load balancers. | `true` / `false` | `false` |
| `use_stateless_rules` | Use stateless NSG rules instead of stateful. | `true` / `false` | `false` |

Additional NSG rule example:

```hcl
allow_rules_workers = {
  "Allow TCP 8080 from VCN" = {
    protocol = 6, port = 8080, source = "10.0.0.0/16", source_type = "CIDR_BLOCK",
  },
}
```

## Cluster

Relevant diagrams:
- [Public control plane topology](./diagrams.md#public-control-plane-topology)
- [Private control plane topology](./diagrams.md#private-control-plane-topology)
- [OIDC discovery flow](./diagrams.md#oidc-discovery-flow)

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_cluster` | Whether to create an OKE cluster. | `true` / `false` | `true` |
| `cluster_name` | Name of the OKE cluster. | string | `"oke"` |
| `cluster_type` | Cluster type. Enhanced clusters support additional features like virtual node pools and workload identity. | `"basic"` / `"enhanced"` | `"basic"` |
| `control_plane_is_public` | Whether the control plane has a public IP. | `true` / `false` | `false` |
| `assign_public_ip_to_control_plane` | Assign a public IP to the API endpoint. | `true` / `false` | `false` |
| `control_plane_nsg_ids` | Additional NSG IDs for the cluster endpoint. | set(string) | `[]` |
| `backend_nsg_ids` | Additional NSG IDs for load balancer backends. Workers and pods NSGs are always included. | set(string) | `[]` |
| `cni_type` | Container Network Interface type. | `"flannel"` / `"npn"` | `"flannel"` |
| `enable_ipv6` | Create a dual-stack (IPv4 and IPv6) cluster. | `true` / `false` | `false` |
| `oke_ip_families` | Override the `ip_families` cluster attribute. | list(string) | `[]` |
| `pods_cidr` | CIDR range for Kubernetes pods. Must not overlap with VCN, worker, or LB subnets. | CIDR string | `"10.244.0.0/16"` |
| `services_cidr` | CIDR range for Kubernetes services. Must not overlap with the VCN CIDR. | CIDR string | `"10.96.0.0/16"` |
| `kubernetes_version` | Kubernetes version for the cluster. | string (e.g. `"v1.34.2"`) | `"v1.34.2"` |
| `cluster_kms_key_id` | KMS key OCID for Kubernetes secrets encryption. | OCID string | `""` |
| `use_signed_images` | Enforce that only signed container images can be deployed. | `true` / `false` | `false` |
| `image_signing_keys` | KMS key IDs used to verify signed images. | set(string) | `[]` |
| `load_balancers` | Type of subnets created for load balancers. | `"public"` / `"internal"` / `"both"` | `"both"` |
| `preferred_load_balancer` | Preferred load balancer subnet type. | `"public"` / `"internal"` | `"public"` |
| `oidc_discovery_enabled` | Enable OIDC discovery for third-party token validation. Requires enhanced cluster. | `true` / `false` | `false` |
| `oidc_token_auth_enabled` | Enable OIDC token authentication via API server flags. Requires enhanced cluster. | `true` / `false` | `false` |
| `oidc_token_authentication_config` | OIDC token authentication configuration (client_id, issuer_url, username_claim, required_claims). | any | `{}` |

Basic cluster example:

```hcl
cluster_name       = "oke-example"
kubernetes_version = "v1.34.2"
```

Enhanced cluster example:

```hcl
cluster_name                      = "oke"
cluster_type                      = "enhanced"
cni_type                          = "flannel"
kubernetes_version                = "v1.34.2"
assign_public_ip_to_control_plane = true
```

OIDC authentication example for GitHub Actions:

```hcl
cluster_type                      = "enhanced"
oidc_token_auth_enabled           = true
oidc_token_authentication_config  = {
  client_id      = "oke-kubernetes-cluster"
  issuer_url     = "https://token.actions.githubusercontent.com"
  username_claim = "sub"
  required_claims = [
    { key = "repository", value = "GITHUB_ACCOUNT/GITHUB_REPOSITORY" },
    { key = "workflow",   value = "oke-oidc" },
    { key = "ref",        value = "refs/heads/main" },
  ]
}
```

## Cluster Add-ons

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `cluster_addons` | Map of cluster addons to enable. Each addon supports `remove_addon_resources_on_delete`, `override_existing`, and `configurations`. | any | `{}` |
| `cluster_addons_to_remove` | Map of cluster addons to remove. Each entry supports `remove_k8s_resources`. | any | `{}` |

Example:

```hcl
cluster_addons = {
  "CertManager" = {
    remove_addon_resources_on_delete = true
    override_existing                = true
    configurations = [
      { key = "numOfReplicas", value = "1" }
    ]
  }
  "NvidiaGpuPlugin" = {
    remove_addon_resources_on_delete = true
  }
}

cluster_addons_to_remove = {
  Flannel = { remove_k8s_resources = true }
}
```

## Workers

Relevant diagrams:
- [Public workers topology](./diagrams.md#public-workers-topology)
- [Private workers topology](./diagrams.md#private-workers-topology)

### Default Pool Configuration

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `cluster_id` | Existing OKE cluster OCID. Required when `create_cluster = false`. | OCID string | `null` |
| `cluster_ca_cert` | Base64+PEM-encoded cluster CA certificate. Required when `create_cluster = false`. | string | `null` |
| `cluster_dns` | Cluster DNS resolver IP address. Required when `create_cluster = false`. | string | `null` |
| `worker_pools` | Map of worker pool definitions. Key is the pool name, value is the pool configuration. | any | `{}` |
| `worker_pool_mode` | Default management mode for worker pools. | `"node-pool"` / `"virtual-node-pool"` / `"instance"` / `"instance-pool"` / `"cluster-network"` / `"compute-cluster"` | `"node-pool"` |
| `worker_pool_size` | Default size for worker pools. | number | `0` |
| `worker_compute_clusters` | Shared compute cluster definitions for use by multiple pools. | map(any) | `{}` |

### Worker Pool Defaults

These parameters set defaults for all worker pools. Individual pools can override these.

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `worker_is_public` | Provision workers with public IPs. | `true` / `false` | `false` |
| `worker_nsg_ids` | Additional NSG IDs for all worker nodes. | list(string) | `[]` |
| `pod_nsg_ids` | Additional NSG IDs for pods (NPN CNI). | list(string) | `[]` |
| `kubeproxy_mode` | Kube-proxy mode. | `"iptables"` / `"ipvs"` | `"iptables"` |
| `worker_block_volume_type` | Block volume attachment type for self-managed workers. | `"paravirtualized"` / `"iscsi"` | `"paravirtualized"` |
| `worker_node_labels` | Default Kubernetes node labels. | map(string) | `{}` |
| `worker_node_metadata` | Additional worker node metadata. | map(string) | `{}` |
| `worker_image_id` | Default image OCID for worker pools. | OCID string | `null` |
| `worker_image_type` | Default image type. `"oke"` uses OKE Oracle Linux images. | `"oke"` / `"custom"` / `"platform"` | `"oke"` |
| `worker_image_os` | Default OS for platform/OKE images. | string | `"Oracle Linux"` |
| `worker_image_os_version` | Default OS version for platform/OKE images. | string | `"8"` |
| `worker_shape` | Default shape for worker instances. | map(any) | `{shape = "VM.Standard.E4.Flex", ocpus = 2, memory = 16, boot_volume_size = 50, boot_volume_vpus_per_gb = 10}` |
| `worker_capacity_reservation_id` | Capacity reservation OCID for worker instances. | OCID string | `null` |
| `worker_preemptible_config` | Preemptible compute configuration. | map(any) | `{}` |
| `worker_cloud_init` | Default cloud-init MIME parts for all pools. | list(map(string)) | `[]` |
| `worker_disable_default_cloud_init` | Disable the default OKE cloud-init. | `true` / `false` | `false` |
| `worker_volume_kms_key_id` | KMS key OCID for boot volume encryption. | OCID string | `null` |
| `worker_pv_transit_encryption` | Enable in-transit encryption for paravirtualized volumes. | `true` / `false` | `false` |
| `worker_legacy_imds_endpoints_disabled` | Disable IMDSv1 endpoint on workers. | `true` / `false` | `false` |
| `max_pods_per_node` | Maximum pods per node (1-110). Only applies with NPN CNI. | number | `31` |
| `platform_config` | Platform configuration for self-managed pools (shielded instances). | object | `null` |
| `agent_config` | Management agent configuration for self-managed pools. | object | `null` |
| `allow_short_container_image_names` | Allow short container image names without full registry path. Requires Kubernetes >= 1.34.0. | `true` / `false` | `false` |

### Worker Pool Entry Configuration

Each entry in the `worker_pools` map supports the following attributes:

| Attribute | Description | Values |
|-----------|-------------|--------|
| `mode` | Worker management mode. Overrides `worker_pool_mode`. | `"node-pool"` / `"virtual-node-pool"` / `"instance"` / `"instance-pool"` / `"cluster-network"` / `"compute-cluster"` |
| `size` | Number of nodes in the pool. | number |
| `shape` | Instance shape name. | string |
| `ocpus` | Number of OCPUs (Flex shapes). | number |
| `memory` | Memory in GB (Flex shapes). | number |
| `boot_volume_size` | Boot volume size in GB. | number |
| `boot_volume_vpus_per_gb` | Boot volume performance (10/20/30-120). Self-managed modes only. | number |
| `description` | Pool description. | string |
| `create` | Whether to create this pool. | `true` / `false` |
| `image_type` | Image type for this pool. | `"oke"` / `"custom"` / `"platform"` |
| `image_id` | Custom image OCID. | OCID string |
| `os` | OS name. | string |
| `os_version` | OS version. | string |
| `node_labels` | Kubernetes node labels. | map(string) |
| `subnet_id` | Custom subnet OCID for this pool. | OCID string |
| `pod_subnet_id` | Custom pod subnet OCID (NPN CNI). | OCID string |
| `nsg_ids` | Additional NSG IDs for this pool. | list(string) |
| `pod_nsg_ids` | Additional pod NSG IDs for this pool (NPN CNI). | list(string) |
| `assign_public_ip` | Assign a public IP to nodes. | `true` / `false` |
| `cloud_init` | Pool-specific cloud-init MIME parts. | list(map(string)) |
| `secondary_vnics` | Secondary VNIC configurations. | map(any) |
| `autoscale` | Enable cluster autoscaler for this pool. | `true` / `false` |
| `min_size` | Minimum pool size for autoscaling. | number |
| `max_size` | Maximum pool size for autoscaling. | number |
| `allow_autoscaler` | Allow cluster autoscaler to manage this pool. | `true` / `false` |
| `ignore_initial_pool_size` | Ignore initial pool size when autoscaling. | `true` / `false` |
| `drain` | Mark pool for draining (disables scheduling, drains through operator). | `true` / `false` |
| `placement_ads` | List of AD numbers for placement. | list(number) |
| `compute_cluster` | Name of a shared compute cluster (compute-cluster mode). | string |
| `instance_ids` | Instance IDs in compute cluster. | list(string) |
| `platform_config` | Platform configuration (shielded instances). | object |
| `agent_config` | Management agent configuration. | object |
| `burst` | CPU bursting configuration for Flex shapes. | `"BASELINE_1_8"` / `"BASELINE_1_2"` |
| `node_cycling_enabled` | Enable node cycling for updates. | `true` / `false` |
| `node_cycling_max_surge` | Max surge during cycling (percentage or number). | string |
| `node_cycling_max_unavailable` | Max unavailable during cycling. | number |
| `node_cycling_mode` | Cycling mode. | `["instance"]` / `["boot_volume"]` |
| `eviction_grace_duration` | Grace duration for eviction in seconds. | number |
| `is_force_delete_after_grace_duration` | Force delete after grace duration. | `true` / `false` |

Basic node pool example:

```hcl
worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  oke-vm-standard = {}
  oke-vm-standard-large = {
    size             = 1
    shape            = "VM.Standard.E4.Flex"
    ocpus            = 8
    memory           = 128
    boot_volume_size = 200
  }
}
```

Autoscaled node pool example:

```hcl
worker_pools = {
  np-autoscaled = {
    size                     = 2
    min_size                 = 1
    max_size                 = 3
    autoscale                = true
    ignore_initial_pool_size = true
  }
}
```

Cluster network (HPC/GPU) example:

```hcl
worker_pools = {
  oke-bm-gpu-rdma = {
    mode          = "cluster-network"
    size          = 1
    shape         = "BM.GPU.B4.8"
    placement_ads = [1]
    image_id      = "ocid1.image..."
    secondary_vnics = {
      "vnic-display-name" = {
        nic_index = 1
        subnet_id = "ocid1.subnet..."
      }
    }
  }
}
```

## Bastion

The bastion instance provides a public SSH entrypoint into the VCN.

See [Bastion access layout](./diagrams.md#bastion-access-layout) for the administrative access path.

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_bastion` | Whether to create a bastion host. | `true` / `false` | `true` |
| `bastion_public_ip` | IP address of an existing bastion. Ignored when `create_bastion = true`. | string | `null` |
| `bastion_allowed_cidrs` | List of CIDR blocks allowed SSH access to the bastion. Set to `["0.0.0.0/0"]` to allow from anywhere. | list(string) | `[]` |
| `bastion_availability_domain` | Availability domain number for the bastion. Defaults to first available. | string | `null` |
| `bastion_nsg_ids` | Additional NSG IDs for the bastion. Combined with the created NSG. | list(string) | `[]` |
| `bastion_user` | SSH user for the bastion host. | string | `"opc"` |
| `bastion_image_id` | Custom image OCID for the bastion. Ignored when `bastion_image_type = "platform"`. | OCID string | `null` |
| `bastion_image_type` | Image type for the bastion. | `"platform"` / `"custom"` | `"platform"` |
| `bastion_image_os` | Platform image OS name. | string | `"Oracle Autonomous Linux"` |
| `bastion_image_os_version` | Platform image OS version. | string | `"8"` |
| `bastion_shape` | Shape of the bastion instance. | map(any) | `{shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 4, boot_volume_size = 50, baseline_ocpu_utilization = 100}` |
| `bastion_is_public` | Whether the bastion is provisioned with a public IP. | `true` / `false` | `true` |
| `bastion_upgrade` | Whether to upgrade bastion packages after provisioning. | `true` / `false` | `false` |
| `bastion_await_cloudinit` | Block Terraform until cloud-init completes on the bastion. | `true` / `false` | `true` |
| `bastion_volume_kms_key_id` | KMS key OCID for bastion boot volume encryption. | OCID string | `null` |
| `bastion_legacy_imds_endpoints_disabled` | Disable IMDSv1 endpoint on the bastion. | `true` / `false` | `true` |

Example:

```hcl
create_bastion              = true
bastion_allowed_cidrs       = ["0.0.0.0/0"]
bastion_image_type          = "platform"
bastion_upgrade             = false
bastion_user                = "opc"

bastion_shape = {
  shape                     = "VM.Standard.E4.Flex"
  ocpus                     = 1
  memory                    = 4
  boot_volume_size          = 50
  baseline_ocpu_utilization = 100
}
```

## Operator

The operator instance provides an environment within the VCN from which the OKE cluster can be managed. It comes pre-installed with kubectl, Helm, and optional tools.

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_operator` | Whether to create an operator host. | `true` / `false` | `true` |
| `operator_availability_domain` | Availability domain for the operator. Defaults to first available. | string | `null` |
| `operator_cloud_init` | Cloud-init MIME parts for custom operator initialization. | list(map(string)) | `[]` |
| `operator_nsg_ids` | Additional NSG IDs for the operator. | list(string) | `[]` |
| `operator_user` | SSH user for the operator host. | string | `"opc"` |
| `operator_image_id` | Custom image OCID for the operator. Ignored when `operator_image_type = "platform"`. | OCID string | `null` |
| `operator_image_os` | Platform image OS name. | string | `"Oracle Linux"` |
| `operator_image_os_version` | Platform image OS version. | string | `"8"` |
| `operator_image_type` | Image type for the operator. | `"platform"` / `"custom"` | `"platform"` |
| `operator_install_helm` | Whether to install Helm on the operator. | `true` / `false` | `true` |
| `operator_install_helm_from_repo` | Install Helm from the package repository. | `true` / `false` | `false` |
| `operator_install_oci_cli_from_repo` | Install OCI CLI from the package repository. | `true` / `false` | `false` |
| `operator_install_istioctl` | Whether to install istioctl on the operator. | `true` / `false` | `false` |
| `operator_install_k8sgpt` | Whether to install k8sgpt on the operator. | `true` / `false` | `false` |
| `operator_install_k9s` | Whether to install k9s on the operator. | `true` / `false` | `false` |
| `operator_install_kubectl_from_repo` | Install kubectl from the package repository. | `true` / `false` | `true` |
| `operator_install_kubectx` | Whether to install kubectx/kubens on the operator. | `true` / `false` | `true` |
| `operator_install_stern` | Whether to install stern on the operator. | `true` / `false` | `false` |
| `operator_shape` | Shape of the operator instance. | map(any) | `{shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 4, boot_volume_size = 50, baseline_ocpu_utilization = 100}` |
| `operator_volume_kms_key_id` | KMS key OCID for operator boot volume encryption. | OCID string | `null` |
| `operator_pv_transit_encryption` | Enable in-transit encryption for paravirtualized volumes. | `true` / `false` | `false` |
| `operator_upgrade` | Whether to upgrade operator packages after provisioning. | `true` / `false` | `false` |
| `operator_private_ip` | IP address of an existing operator. Ignored when `create_operator = true`. | string | `null` |
| `operator_await_cloudinit` | Block Terraform until cloud-init completes on the operator. | `true` / `false` | `true` |
| `operator_legacy_imds_endpoints_disabled` | Disable IMDSv1 endpoint on the operator. | `true` / `false` | `true` |

Example with cloud-init:

```hcl
create_operator     = true
operator_upgrade    = false
operator_user       = "opc"

operator_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Operator cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config"
  }
]

operator_shape = {
  shape                     = "VM.Standard.E4.Flex"
  ocpus                     = 1
  memory                    = 4
  boot_volume_size          = 50
  baseline_ocpu_utilization = 100
}
```

## Extensions

### Cilium

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `cilium_install` | Whether to install Cilium. | `true` / `false` | `false` |
| `cilium_reapply` | Reapply Cilium Helm release on every Terraform apply. | `true` / `false` | `false` |
| `cilium_namespace` | Kubernetes namespace for Cilium. | string | `"kube-system"` |
| `cilium_helm_version` | Cilium Helm chart version. | string | `"1.16.3"` |
| `cilium_helm_values` | Helm values for Cilium. | any | `{}` |
| `cilium_helm_values_files` | List of Helm values files for Cilium. | list(string) | `[]` |

### Multus

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `multus_install` | Whether to install Multus CNI. | `true` / `false` | `false` |
| `multus_namespace` | Kubernetes namespace for Multus. | string | `"network"` |
| `multus_daemonset_url` | URL to the Multus daemonset manifest. Determined automatically by default. | string | `null` |
| `multus_version` | Multus version. | string | `"3.9.3"` |

### SR-IOV Device Plugin

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `sriov_device_plugin_install` | Whether to install the SR-IOV device plugin. | `true` / `false` | `false` |
| `sriov_device_plugin_namespace` | Kubernetes namespace. | string | `"network"` |
| `sriov_device_plugin_daemonset_url` | URL to the daemonset manifest. Determined automatically by default. | string | `null` |
| `sriov_device_plugin_version` | SR-IOV device plugin version. | string | `"master"` |

### SR-IOV CNI Plugin

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `sriov_cni_plugin_install` | Whether to install the SR-IOV CNI plugin. | `true` / `false` | `false` |
| `sriov_cni_plugin_namespace` | Kubernetes namespace. | string | `"network"` |
| `sriov_cni_plugin_daemonset_url` | URL to the daemonset manifest. Determined automatically by default. | string | `null` |
| `sriov_cni_plugin_version` | SR-IOV CNI plugin version. | string | `"master"` |

### RDMA CNI Plugin

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `rdma_cni_plugin_install` | Whether to install the RDMA CNI plugin. | `true` / `false` | `false` |
| `rdma_cni_plugin_namespace` | Kubernetes namespace. | string | `"network"` |
| `rdma_cni_plugin_daemonset_url` | URL to the daemonset manifest. Determined automatically by default. | string | `null` |
| `rdma_cni_plugin_version` | RDMA CNI plugin version. | string | `"master"` |

### Whereabouts

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `whereabouts_install` | Whether to install Whereabouts IPAM. | `true` / `false` | `false` |
| `whereabouts_namespace` | Kubernetes namespace. | string | `"default"` |
| `whereabouts_daemonset_url` | URL to the daemonset manifest. Determined automatically by default. | string | `null` |
| `whereabouts_version` | Whereabouts version. | string | `"master"` |

### Metrics Server

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `metrics_server_install` | Whether to install Metrics Server. | `true` / `false` | `false` |
| `metrics_server_namespace` | Kubernetes namespace. | string | `"metrics"` |
| `metrics_server_helm_version` | Helm chart version. | string | `"3.8.3"` |
| `metrics_server_helm_values` | Helm values. | map(string) | `{}` |
| `metrics_server_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### Cluster Autoscaler

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `cluster_autoscaler_install` | Whether to install the standalone Cluster Autoscaler. | `true` / `false` | `false` |
| `cluster_autoscaler_namespace` | Kubernetes namespace. | string | `"kube-system"` |
| `cluster_autoscaler_helm_version` | Helm chart version. | string | `"9.24.0"` |
| `cluster_autoscaler_helm_values` | Helm values. | map(string) | `{}` |
| `cluster_autoscaler_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### Prometheus

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `prometheus_install` | Whether to install Prometheus. | `true` / `false` | `false` |
| `prometheus_reapply` | Reapply Prometheus Helm release on every apply. | `true` / `false` | `false` |
| `prometheus_namespace` | Kubernetes namespace. | string | `"metrics"` |
| `prometheus_helm_version` | Helm chart version. | string | `"45.2.0"` |
| `prometheus_helm_values` | Helm values. | map(string) | `{}` |
| `prometheus_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### DCGM Exporter

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `dcgm_exporter_install` | Whether to install the DCGM Exporter for GPU metrics. | `true` / `false` | `false` |
| `dcgm_exporter_reapply` | Reapply DCGM Exporter Helm release on every apply. | `true` / `false` | `false` |
| `dcgm_exporter_namespace` | Kubernetes namespace. | string | `"metrics"` |
| `dcgm_exporter_helm_version` | Helm chart version. | string | `"3.1.5"` |
| `dcgm_exporter_helm_values` | Helm values. | map(string) | `{}` |
| `dcgm_exporter_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### Gatekeeper

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `gatekeeper_install` | Whether to install Gatekeeper (OPA). | `true` / `false` | `false` |
| `gatekeeper_namespace` | Kubernetes namespace. | string | `"kube-system"` |
| `gatekeeper_helm_version` | Helm chart version. | string | `"3.11.0"` |
| `gatekeeper_helm_values` | Helm values. | map(string) | `{}` |
| `gatekeeper_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### MPI Operator

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `mpi_operator_install` | Whether to install the MPI Operator. | `true` / `false` | `false` |
| `mpi_operator_namespace` | Kubernetes namespace. | string | `"default"` |
| `mpi_operator_deployment_url` | URL to the deployment manifest. Determined automatically by default. | string | `null` |
| `mpi_operator_version` | MPI Operator version. | string | `"0.4.0"` |

### ArgoCD

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `argocd_install` | Whether to install ArgoCD. | `true` / `false` | `false` |
| `argocd_namespace` | Kubernetes namespace. | string | `"argocd"` |
| `argocd_helm_version` | Helm chart version. | string | `"8.1.2"` |
| `argocd_helm_values` | Helm values. | map(string) | `{}` |
| `argocd_helm_values_files` | List of Helm values files. | list(string) | `[]` |

### Service Accounts

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `create_service_account` | Whether to create Kubernetes service accounts with RBAC. | `true` / `false` | `false` |
| `service_accounts` | Map of service account definitions. Each supports `sa_name`, `sa_namespace`, `sa_cluster_role`, `sa_cluster_role_binding`, `sa_role`, `sa_role_binding`. | map(any) | Seeded with a default `kubeconfigsa` entry |

Example:

```hcl
create_service_account = true

service_accounts = {
  example_cluster_role_binding = {
    sa_name                 = "sa1"
    sa_namespace            = "kube-system"
    sa_cluster_role         = "cluster-admin"
    sa_cluster_role_binding = "sa1-crb"
  }
}
```

## Utilities

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `await_node_readiness` | Block Terraform until nodes are ready. | `"none"` / `"one"` / `"all"` | `"none"` |
| `ocir_email_address` | Email address for OCIR secret. | string | `null` |
| `ocir_secret_id` | OCIR secret OCID from OCI Vault. | OCID string | `null` |
| `ocir_secret_name` | Name of the Kubernetes Docker registry secret. | string | `"ocirsecret"` |
| `ocir_secret_namespace` | Kubernetes namespace for the OCIR secret. | string | `"default"` |
| `ocir_username` | Username for OCIR secret access. | string | `null` |
| `worker_drain_ignore_daemonsets` | Ignore DaemonSet pods when draining workers. | `true` / `false` | `true` |
| `worker_drain_delete_local_data` | Delete local data when draining workers. | `true` / `false` | `true` |
| `worker_drain_timeout_seconds` | Timeout for worker draining in seconds. | number | `900` |

## Tagging

| Parameter | Description | Values | Default |
| --- | --- | --- | --- |
| `freeform_tags` | Freeform tags applied to all resources. | any | `{access = "private", environment = "dev", role = "oke", version = "5"}` |
| `defined_tags` | Defined tags applied to all resources. Requires `use_defined_tags = true`. | any | `{}` |
| `bastion_defined_tags` | Defined tags for bastion resources only. | any | `{}` |
| `bastion_freeform_tags` | Freeform tags for bastion resources only. | any | `{}` |
| `cluster_defined_tags` | Defined tags for cluster resources only. | any | `{}` |
| `cluster_freeform_tags` | Freeform tags for cluster resources only. | any | `{}` |
| `iam_defined_tags` | Defined tags for IAM resources only. | any | `{}` |
| `iam_freeform_tags` | Freeform tags for IAM resources only. | any | `{}` |
| `network_defined_tags` | Defined tags for network resources only. | any | `{}` |
| `network_freeform_tags` | Freeform tags for network resources only. | any | `{}` |
| `operator_defined_tags` | Defined tags for operator resources only. | any | `{}` |
| `operator_freeform_tags` | Freeform tags for operator resources only. | any | `{}` |
| `persistent_volume_defined_tags` | Defined tags for persistent volume resources only. | any | `{}` |
| `persistent_volume_freeform_tags` | Freeform tags for persistent volume resources only. | any | `{}` |
| `service_lb_defined_tags` | Defined tags for service load balancer resources only. | any | `{}` |
| `service_lb_freeform_tags` | Freeform tags for service load balancer resources only. | any | `{}` |
| `workers_defined_tags` | Defined tags for worker resources only. | any | `{}` |
| `workers_freeform_tags` | Freeform tags for worker resources only. | any | `{}` |

## Validation Rules

- `compartment_id` is required.
- Either `ssh_public_key` or `ssh_public_key_path` must be provided when creating bastion or operator.
- `bastion_image_type = "custom"` requires `bastion_image_id`.
- `operator_image_type = "custom"` requires `operator_image_id`.
- `cni_type = "npn"` requires `cluster_type = "enhanced"`.
- `oidc_discovery_enabled = true` requires `cluster_type = "enhanced"`.
- `oidc_token_auth_enabled = true` requires `cluster_type = "enhanced"`.
- `worker_pool_mode = "node-pool"` is the only mode that supports OKE-managed node pools.
- `worker_pool_mode = "cluster-network"` or `"instance-pool"` or `"instance"` are self-managed modes.
- Pods CIDR must not overlap with VCN, worker, or load balancer subnets.
- Services CIDR must not overlap with the VCN CIDR.

## Outputs

| Output | Description |
|--------|-------------|
| `state_id` | Generated state identifier. |
| `cluster_id` | OKE cluster OCID. |
| `cluster_endpoints` | Cluster endpoints (public and private). |
| `cluster_oidc_discovery_endpoint` | OIDC discovery endpoint URL. |
| `cluster_kubeconfig` | Kubernetes kubeconfig YAML (requires `output_detail = true`). |
| `cluster_ca_cert` | Base64-encoded cluster CA certificate. |
| `apiserver_private_host` | Private API server hostname. |
| `bastion_id` | Bastion instance OCID. |
| `bastion_public_ip` | Bastion public IP address. |
| `ssh_to_bastion` | SSH command to connect to the bastion. |
| `operator_id` | Operator instance OCID. |
| `operator_private_ip` | Operator private IP address. |
| `ssh_to_operator` | SSH command to connect to the operator (via bastion). |
| `vcn_id` | VCN OCID. |
| `ig_route_table_id` | Internet gateway route table OCID. |
| `nat_route_table_id` | NAT gateway route table OCID. |
| `drg_id` | Dynamic Routing Gateway OCID (when created). |
| `lpg_all_attributes` | Local Peering Gateway attributes. |
| `bastion_subnet_id` | Bastion subnet OCID. |
| `bastion_subnet_cidr` | Bastion subnet CIDR. |
| `operator_subnet_id` | Operator subnet OCID. |
| `operator_subnet_cidr` | Operator subnet CIDR. |
| `control_plane_subnet_id` | Control plane subnet OCID. |
| `control_plane_subnet_cidr` | Control plane subnet CIDR. |
| `worker_subnet_id` | Worker subnet OCID. |
| `worker_subnet_cidr` | Worker subnet CIDR. |
| `pod_subnet_id` | Pod subnet OCID. |
| `pod_subnet_cidr` | Pod subnet CIDR. |
| `int_lb_subnet_id` | Internal load balancer subnet OCID. |
| `int_lb_subnet_cidr` | Internal load balancer subnet CIDR. |
| `pub_lb_subnet_id` | Public load balancer subnet OCID. |
| `pub_lb_subnet_cidr` | Public load balancer subnet CIDR. |
| `fss_subnet_id` | FSS subnet OCID. |
| `fss_subnet_cidr` | FSS subnet CIDR. |
| `bastion_nsg_id` | Bastion NSG OCID. |
| `operator_nsg_id` | Operator NSG OCID. |
| `control_plane_nsg_id` | Control plane NSG OCID. |
| `int_lb_nsg_id` | Internal load balancer NSG OCID. |
| `pub_lb_nsg_id` | Public load balancer NSG OCID. |
| `worker_nsg_id` | Worker NSG OCID. |
| `pod_nsg_id` | Pod NSG OCID. |
| `fss_nsg_id` | FSS NSG OCID. |
| `network_security_rules` | Map of all NSG security rules (requires `output_detail = true`). |
| `availability_domains` | Map of availability domains. |
| `dynamic_group_ids` | IAM dynamic group OCIDs. |
| `policy_statements` | IAM policy statements. |
| `worker_pools` | Worker pool details. |
| `worker_instances` | Worker instance details. |
| `worker_pool_ids` | Worker pool OCIDs. |
| `worker_pool_ips` | Worker pool IP addresses. |
