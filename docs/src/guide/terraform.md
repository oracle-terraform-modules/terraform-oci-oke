# OKE Terraform Module

## Usage

### Create

Initialize a working directory containing Terraform configuration files, and optionally upgrade module dependencies:
```
terraform init -upgrade
```

Run the plan and apply commands to create OKE cluster and other components:
```
terraform plan
terraform apply
```

You can create a Kubernetes cluster with the latest version of Kubernetes available in OKE using this terraform script. By default the kubernetes_version parameter in terraform.tfvars.example is set as "LATEST". Refer to {uri-terraform-options}#oke[Terraform Options] for other available parameters for OKE.

Use the parameter *cluster_name* to change the name of the cluster as per your needs.

### Connect

**NOTE:** TODO Add content

kubectl installed on the operator host by default and the kubeconfig file is set in the default location (~/.kube/config) so you don't need to set the KUBECONFIG environment variable every time you log in to the operator host. 

****
The `instance principal` of the operator must be granted `MANAGE` on target cluster for configuration of an admin user context.
* [Steps to Enable Instances to Call Services](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm#setup)
* [Writing Policies for OCI Kubernetes Engine](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/contengpolicyreference.htm)
****

An alias "*k*" will be created for kubectl on the operator host. 

If you would like to use kubectl locally, {uri-install-kubectl}[install kubectl]. Then, set the KUBECONFIG to the config file path.

```
export KUBECONFIG=path/to/kubeconfig
```

.To be able to get the kubeconfig file, you will need to get the credentials with terraform and store in the preferred storage format (e.g: file, vault, bucket...):
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

****
*Ensure you install the same kubectl version as the OKE Kubernetes version for compatibility.*
****

#### Update

**NOTE:** TODO Add content

#### Destroy

**NOTE:** TODO Add content

Run the below command to destroy the infrastructure created by Terraform:

```
terraform destroy
```

****
*Only infrastructure created by Terraform will be destroyed.*
****
