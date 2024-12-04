# Getting started

[uri-oci-cli]: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cliconcepts.htm#Command_Line_Interface_CLI
[uri-oci-oke]: https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm#top
[uri-terraform-oci-oke]: https://github.com/oracle-terraform-modules/terraform-oci-oke
[uri-terraform-options]: ./inputs_submodule.html#cluster

This module automates the provisioning of an [OKE][uri-oci-oke] cluster.

```admonish notice
The documentation here is for 5.x **only**. The documentation for earlier versions can be found on the [GitHub repo][uri-terraform-oci-oke].
```

## Usage

### Clone the repo

Clone the git repo:

```
git clone https://github.com/oracle-terraform-modules/terraform-oci-oke.git tfoke
cd tfoke
```

### Create

1. Create 2 OCI providers and add them to providers.tf:

```
provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.region
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
}

provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.home_region
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  alias            = "home"
}
```

2. Initialize a working directory containing Terraform configuration files, and optionally upgrade module dependencies:
```
terraform init --upgrade
```

3. Create a terraform.tfvars and provide the necessary parameters:

```
# Identity and access parameters
api_fingerprint      = "00:ab:12:34:56:cd:78:90:12:34:e5:fa:67:89:0b:1c"
api_private_key_path = "~/.oci/oci_rsa.pem"

home_region = "us-ashburn-1"
region      = "ap-sydney-1"
tenancy_id  = "ocid1.tenancy.oc1.."
user_id     = "ocid1.user.oc1.."

# general oci parameters
compartment_id = "ocid1.compartment.oc1.."
timezone       = "Australia/Sydney"

# ssh keys
ssh_private_key_path = "~/.ssh/id_ed25519"
ssh_public_key_path  = "~/.ssh/id_ed25519.pub"

# networking
create_vcn               = true
assign_dns               = true
lockdown_default_seclist = true
vcn_cidrs                = ["10.0.0.0/16"]
vcn_dns_label            = "oke"
vcn_name                 = "oke"

# Subnets
subnets = {
  bastion  = { newbits = 13, netnum = 0, dns_label = "bastion", create="always" }
  operator = { newbits = 13, netnum = 1, dns_label = "operator", create="always" }
  cp       = { newbits = 13, netnum = 2, dns_label = "cp", create="always" }
  int_lb   = { newbits = 11, netnum = 16, dns_label = "ilb", create="always" }
  pub_lb   = { newbits = 11, netnum = 17, dns_label = "plb", create="always" }
  workers  = { newbits = 2, netnum = 1, dns_label = "workers", create="always" }
  pods     = { newbits = 2, netnum = 2, dns_label = "pods", create="always" }
}

# bastion
create_bastion           = true
bastion_allowed_cidrs    = ["0.0.0.0/0"]
bastion_user             = "opc"

# operator
create_operator                = true
operator_install_k9s           = true


# iam
create_iam_operator_policy   = "always"
create_iam_resources         = true

create_iam_tag_namespace = false // true/*false
create_iam_defined_tags  = false // true/*false
tag_namespace            = "oke"
use_defined_tags         = false // true/*false

# cluster
create_cluster     = true
cluster_name       = "oke"
cni_type           = "flannel"
kubernetes_version = "v1.29.1"
pods_cidr          = "10.244.0.0/16"
services_cidr      = "10.96.0.0/16"

# Worker pool defaults
worker_pool_size = 0
worker_pool_mode = "node-pool"

# Worker defaults
await_node_readiness     = "none"

worker_pools = {
  np1 = {
    shape              = "VM.Standard.E4.Flex",
    ocpus              = 2,
    memory             = 32,
    size               = 1,
    boot_volume_size   = 50,
    kubernetes_version = "v1.29.1"
  }
  np2 = {
     shape            = "VM.Standard.E4.Flex",
     ocpus            = 2,
     memory           = 32,
     size             = 3,
     boot_volume_size = 150,
     kubernetes_version = "v1.29.1"
  }
}

# Security
allow_node_port_access       = false
allow_worker_internet_access = true
allow_worker_ssh_access      = true
control_plane_allowed_cidrs  = ["0.0.0.0/0"]
control_plane_is_public      = false
load_balancers               = "both"
preferred_load_balancer      = "public"

```

4. Run the plan and apply commands to create OKE cluster and other components:
```
terraform plan
terraform apply
```

You can create a Kubernetes cluster with the latest version of Kubernetes available in OKE using this terraform script.

### Connect

**NOTE:** TODO Add content

kubectl is installed on the operator host by default and the kubeconfig file is set in the default location (~/.kube/config) so you don't need to set the KUBECONFIG environment variable every time you log in to the operator host. 

****
The `instance principal` of the operator must be granted `MANAGE` on target cluster for configuration of an admin user context.
* [Steps to Enable Instances to Call Services](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm#setup)
* [Writing Policies for OCI Kubernetes Engine](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/contengpolicyreference.htm)
****

An alias "*k*" will be created for kubectl on the operator host. 

If you would like to use kubectl locally, first [install and configure OCI CLI][uri-oci-cli] locally. Then, install kubectl and set the KUBECONFIG to the config file path.

```
export KUBECONFIG=path/to/kubeconfig
```

To be able to get the kubeconfig file, you will need to get the credentials with terraform and store in the preferred storage format (e.g: file, vault, bucket...):
```
# OKE cluster creation.
module "oke_my_cluster" {
#...
}

# Obtain cluster Kubeconfig.
data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = module.oke_my_cluster.cluster_id
}

# Store kubeconfig in vault.
resource "vault_generic_secret" "kube_config" {
  path = "my/cluster/path/kubeconfig"
  data_json = jsonencode({
    "data" : data.oci_containerengine_cluster_kube_config.kube_config.content
  })
}

# Store kubeconfig in file.
resource "local_file" "kube_config" {
  content         = data.oci_containerengine_cluster_kube_config.kube_config.content
  filename        = "/tmp/kubeconfig"
  file_permission = "0600"
}
```

```admonish tip
Ensure you install the same kubectl version as the OKE Kubernetes version for compatibility.
```

### Update

**NOTE:** TODO Add content

### Destroy

Run the below command to destroy the infrastructure created by Terraform:

```
terraform destroy
```

You can also do targeted destroy e.g.

```
terraform destroy --target=module.workers
```

```admonish notice
*Only infrastructure created by Terraform will be destroyed.*
```
