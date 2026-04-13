# Quickstart

1. [Assumptions](#assumptions)
2. [Pre-requisites](#pre-requisites)
3. [Instructions](#instructions)
4. [Connect to the cluster](#connect-to-the-cluster)
5. [Update the cluster](#update-the-cluster)
6. [Destroy the cluster](#destroy-the-cluster)
7. [Related documentation](#related-documentation)

### Assumptions

1. You have set up the [required API keys](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm).
2. You know the [required OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#five).
3. You have the necessary [permissions](./prerequisites.md#identity-and-access-management-rights).
4. You have an SSH key pair available.

### Pre-requisites

1. `git` is installed.
2. An SSH client is installed.
3. Terraform 1.3.0+ is installed.

See [Pre-requisites](./prerequisites.md) for detailed setup instructions.

### Instructions

#### Provisioning using this git repo

1. Clone the repo:

```bash
git clone https://github.com/oracle-terraform-modules/terraform-oci-oke.git tfoke

cd tfoke
```

Create a `terraform.tfvars` file for your environment. This repository does not ship a generic root `terraform.tfvars.example`.

2. Create a `provider.tf` file and add the following:

```hcl
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.30.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.region
}

provider "oci" {
  alias            = "home"
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = coalesce(var.home_region, var.region)
}
```

Provider credentials are intentionally configured in `provider.tf`, not in `terraform.tfvars`.

3. Set mandatory provider parameters:

- `api_fingerprint`
- `api_private_key_path`
- `region`
- `tenancy_id`
- `user_id`

4. Set other required parameters:

- `compartment_id`
- One of `ssh_public_key` or `ssh_public_key_path`

5. Set cluster and worker parameters. At minimum, configure:

```hcl
# Cluster
create_cluster     = true
cluster_name       = "oke-cluster"
kubernetes_version = "v1.34.2"

# Workers
worker_pool_mode = "node-pool"
worker_pool_size = 1

worker_pools = {
  np1 = {
    size  = 1
  }
}
```

6. Optional parameters to override (see [Terraform Options](./terraformoptions.md) for the full list):

- Cluster: `cluster_type`, `cni_type`, `control_plane_is_public`, `pods_cidr`, `services_cidr`
- Workers: `worker_shape`, `worker_image_type`, `worker_image_os`, `worker_image_os_version`
- Network: `vcn_cidrs`, `subnets`, `nsgs`, `load_balancers`
- Bastion: `create_bastion`, `bastion_shape`, `bastion_allowed_cidrs`
- Operator: `create_operator`, `operator_shape`, `operator_upgrade`

7. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

8. Retrieve the cluster and access information:

```bash
terraform output cluster_id
terraform output cluster_endpoints
terraform output ssh_to_bastion
terraform output ssh_to_operator
```

If you want Terraform to emit `cluster_kubeconfig`, also set:

```hcl
output_detail = true
```

### Connect to the cluster

#### Via the operator host

1. SSH to the operator through the bastion:

```bash
# Use the output from terraform output ssh_to_operator
ssh -o ProxyCommand='ssh -W %h:%p -i ~/.ssh/oke_key opc@<bastion_ip>' -i ~/.ssh/oke_key opc@<operator_ip>
```

2. Verify connectivity:

```bash
kubectl get nodes
```

#### Via kubeconfig

1. Retrieve the kubeconfig:

```bash
terraform output -raw cluster_kubeconfig > ~/.kube/config-oke
export KUBECONFIG=~/.kube/config-oke
```

`cluster_kubeconfig` is only populated when `output_detail = true`.

2. Verify connectivity:

```bash
kubectl get nodes
```

### Update the cluster

To update the infrastructure:

```bash
# Modify terraform.tfvars as needed
terraform plan
terraform apply
```

Common updates:
- **Kubernetes version**: Change `kubernetes_version` and run `terraform apply`
- **Worker pool size**: Adjust `worker_pool_size` or individual pool `size`
- **Add worker pools**: Add entries to the `worker_pools` map
- **Extensions**: Enable extensions by setting `<extension>_install = true`

### Destroy the cluster

```bash
terraform destroy
```

### Related documentation

- [All Terraform configuration options](./terraformoptions.md) for this module
- [Example configurations](https://github.com/oracle-terraform-modules/terraform-oci-oke/tree/main/examples)
- [Pre-requisites](./prerequisites.md)
