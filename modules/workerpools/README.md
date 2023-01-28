# Worker pools

This sub-module supports different modes of OKE worker node management with advanced configuration.

## Usage
Worker pools are configured with the optional `worker_pools` array.

The module is implemented in the parent module for general use, and can also be used directly by running `terraform init/apply` in this directory or with a separate state. In this case, the `worker_pools` module adds pools to an existing cluster.

1. `cp vars-profile.auto.tfvars.example vars-profile.auto.tfvars`
1. Define `Required parameters`
1. Review defaults and `worker_pools`
1. `terraform init`, `terraform apply` - *update *
1. *e.g.* change `worker_pools[x]` *size from `1` -> `10` - scale up group*
1. *e.g.* change `worker_pools[y]` *size from `1` -> `0` - suspend group, retain instance configuration, pool resources*
1. *e.g.* change `worker_pools[z]` *create from `true` -> `false` - destroy group, retain definition*
1. *e.g.* add `worker_pools[a]` - *create new group*
1. *e.g.* remove `worker_pools[x]` - *destroy group*
1. *e.g.* `terraform refresh` *update convenience variables e.g. worker_primary_ips*

### Mode
The `mode` parameter determines the mechanism used to provision and manage nodes in the worker pool. Currently the only available mode is `node-pool`.

#### **`node-pool`** _(default)_
See [Scaling Kubernetes Clusters and Node Pools](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengscalingkubernetesclustersnodepools.htm) for more information.
```yaml
example-pool = {
    mode             = "node-pool",
    image_id         = "ocid1.image...",
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,
    memory           = 16,
    boot_volume_size = 150,
    size             = 1,
}
```

### Defaults
Many parameters to a worker pool can be defined at multiple levels, taken in priority: `Group > Variable > built-in default`. This enables sparse definition of worker pools that share many traits.
```yaml
label_prefix                   = ""
worker_pool_enabled           = true
worker_pool_size              = 0
worker_image_id          = "ocid1.image..." # Required here and/or on group
worker_pool_mode              = "node-pool"
worker_pool_shape             = "VM.Standard.E4.Flex"
worker_pool_ocpus             = 2
worker_pool_memory            = 16
worker_pool_boot_volume_size  = 100
worker_nsg_ids                 = []
worker_compartment_id          = "" # Defaults to compartment_id when empty
worker_pool_subnet_id = "" # Defaults to Terraform-managed when empty
worker_pools                  = [
  np0 = {}, # All defaults
  np1 = { mode = "node-pool", nsg_ids = ["ocid1.networksecuritygroup..."] },
  np2 = { mode = "node-pool", enabled = false },
  np3 = { mode = "node-pool", enabled = false,
    shape = "VM.Standard.E4.Flex", ocpus = 4, memory = 32, boot_volume_size = 150 }
]
```

### Generated reference
The content below is generated/updated with:
```shell
terraform-docs markdown table --hide-empty=true --hide=modules,providers --output-file=./README.md .
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 4.67.3 |

## Resources

| Name | Type |
|------|------|
| [oci_containerengine_node_pool.nodepools](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [cloudinit_config.worker_np](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [oci_containerengine_cluster_kube_config.kube_config](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/containerengine_cluster_kube_config) | data source |
| [oci_containerengine_clusters.wg_clusters](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/containerengine_clusters) | data source |
| [oci_containerengine_node_pool_option.np_options](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/containerengine_node_pool_option) | data source |
| [oci_identity_availability_domains.ad_list](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_fingerprint"></a> [api\_fingerprint](#input\_api\_fingerprint) | Fingerprint of the API private key to use with OCI API. | `string` | `""` | no |
| <a name="input_api_private_key"></a> [api\_private\_key](#input\_api\_private\_key) | The contents of the private key file to use with OCI API, optionally base64-encoded. This takes precedence over private\_key\_path if both are specified in the provider. | `string` | `""` | no |
| <a name="input_api_private_key_password"></a> [api\_private\_key\_password](#input\_api\_private\_key\_password) | The corresponding private key password to use with the api private key if it is encrypted. | `string` | `""` | no |
| <a name="input_api_private_key_path"></a> [api\_private\_key\_path](#input\_api\_private\_key\_path) | The path to the OCI API private key. | `string` | `""` | no |
| <a name="input_apiserver_host"></a> [apiserver\_host](#input\_apiserver\_host) | Cluster apiserver IP address only e.g. 10.0.0.1. Resolved automatically when OKE cluster is found using cluster\_id. | `string` | `""` | no |
| <a name="input_boot_volume_size"></a> [boot\_volume\_size](#input\_boot\_volume\_size) | Default size in GB for the boot volume of created worker nodes | `number` | `50` | no |
| <a name="input_cloudinit"></a> [cloudinit](#input\_cloudinit) | Base64-encoded cloud init script to run on instance boot | `string` | `""` | no |
| <a name="input_cluster_ca_cert"></a> [cluster\_ca\_cert](#input\_cluster\_ca\_cert) | Cluster CA certificate. Required for unmanaged instance pools for secure control plane connection. | `string` | `""` | no |
| <a name="input_cluster_dns"></a> [cluster\_dns](#input\_cluster\_dns) | Cluster DNS resolver IP address | `string` | `"10.96.5.5"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | An existing OKE cluster ID for worker nodes to join. Resolved automatically when OKE control plane is managed within same Terraform state. | `string` | `""` | no |
| <a name="input_cni_type"></a> [cni\_type](#input\_cni\_type) | The CNI for the cluster. Choose between flannel or npn | `string` | `"flannel"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The compartment id where resources will be created. | `string` | `""` | no |
| <a name="input_compartment_ocid"></a> [compartment\_ocid](#input\_compartment\_ocid) | A compartment OCID automatically populated by Resource Manager. | `string` | `""` | no |
| <a name="input_config_file_profile"></a> [config\_file\_profile](#input\_config\_file\_profile) | The profile within the OCI config file to use. | `string` | `"DEFAULT"` | no |
| <a name="input_current_user_ocid"></a> [current\_user\_ocid](#input\_current\_user\_ocid) | A user OCID automatically populated by Resource Manager. | `string` | `""` | no |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | Tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_enable_pv_encryption_in_transit"></a> [enable\_pv\_encryption\_in\_transit](#input\_enable\_pv\_encryption\_in\_transit) | Whether to enable in-transit encryption for the data volume's paravirtualized attachment. This field applies to both block volumes and boot volumes. The default value is false | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Default for whether to apply resources for a group | `bool` | `true` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | Tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The tenancy's home region. Required to perform identity operations. | `string` | `""` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Default image OCID for worker pools when unspecified and image\_type = custom | `string` | `""` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | Whether to use a Platform, OKE or custom image. When custom is set, the image\_id must be specified. | `string` | `"custom"` | no |
| <a name="input_kubeproxy_mode"></a> [kubeproxy\_mode](#input\_kubeproxy\_mode) | The kube-proxy mode to use for a worker node. | `string` | `"iptables"` | no |
| <a name="input_label_prefix"></a> [label\_prefix](#input\_label\_prefix) | A string that will be prepended to all resources | `string` | `""` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Default memory in GB for flex shapes | `number` | `16` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Default management mode for worker pools when unspecified | `string` | `"node-pool"` | no |
| <a name="input_network_compartment_id"></a> [network\_compartment\_id](#input\_network\_compartment\_id) | The compartment id where network resources will be created. | `string` | `""` | no |
| <a name="input_ocpus"></a> [ocpus](#input\_ocpus) | Default ocpus for flex shapes | `number` | `1` | no |
| <a name="input_os"></a> [os](#input\_os) | The name of image to use. | `string` | `"Oracle Linux"` | no |
| <a name="input_os_version"></a> [os\_version](#input\_os\_version) | The version of operating system to use for the worker nodes. | `string` | `"7.9"` | no |
| <a name="input_pod_nsg_ids"></a> [pod\_nsg\_ids](#input\_pod\_nsg\_ids) | An additional list of network security group (NSG) OCIDs for pod security | `list(string)` | `[]` | no |
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id) | The subnet OCID used for pods when cni\_type = npn | `string` | `""` | no |
| <a name="input_primary_subnet_id"></a> [primary\_subnet\_id](#input\_primary\_subnet\_id) | The subnet OCID used for instances | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The OCI region where OKE resources will be created. | `string` | `"us-ashburn-1"` | no |
| <a name="input_shape"></a> [shape](#input\_shape) | Default shape for instance pools | `string` | `"VM.Standard.E4.Flex"` | no |
| <a name="input_size"></a> [size](#input\_size) | Default number of desired nodes for created worker pools | `number` | `0` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | n/a | `string` | `""` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | n/a | `string` | `""` | no |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The tenancy id of the OCI Cloud Account in which to create the resources. | `string` | `""` | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | A tenancy OCID automatically populated by Resource Manager. | `string` | `""` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The preferred timezone for the worker nodes | `string` | `"Etc/UTC"` | no |
| <a name="input_use_volume_encryption"></a> [use\_volume\_encryption](#input\_use\_volume\_encryption) | Whether to use OCI KMS to encrypt Kubernetes Nodepool's boot/block volume. | `bool` | `false` | no |
| <a name="input_user_id"></a> [user\_id](#input\_user\_id) | The id of the user that terraform will use to create the resources. | `string` | `""` | no |
| <a name="input_volume_kms_key_id"></a> [volume\_kms\_key\_id](#input\_volume\_kms\_key\_id) | The OCID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption. | `string` | `""` | no |
| <a name="input_worker_compartment_id"></a> [worker\_compartment\_id](#input\_worker\_compartment\_id) | The compartment id where worker pool resources will be created. | `string` | `""` | no |
| <a name="input_worker_pools"></a> [worker\_groups](#input\_worker\_groups) | Tuple of OKE worker pools where each key maps to the OCID of an OCI resource, and value contains its definition | `any` | `{}` | no |
| <a name="input_worker_nsg_ids"></a> [worker\_nsg\_ids](#input\_worker\_nsg\_ids) | An additional list of network security groups (NSG) OCIDs for node security | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apiserver_endpoint"></a> [apiserver\_endpoint](#output\_apiserver\_endpoint) | OKE cluster apiserver private IP address |
| <a name="output_cloudinit_node_pool"></a> [cloudinit\_node\_pool](#output\_cloudinit\_node\_pool) | Node pool worker cloud-init |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | OKE cluster |
| <a name="output_cluster_ca_cert"></a> [cluster\_ca\_cert](#output\_cluster\_ca\_cert) | OKE cluster CA certificate |
| <a name="output_enabled_worker_pools"></a> [enabled\_worker\_groups](#output\_enabled\_worker\_groups) | Enabled worker pools |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | OKE cluster kubeconfig |
| <a name="output_np_options"></a> [np\_options](#output\_np\_options) | OKE node pool options |
| <a name="output_worker_availability_domains"></a> [worker\_availability\_domains](#output\_worker\_availability\_domains) | Worker availability domains |
| <a name="output_worker_pool_ids"></a> [worker\_group\_ids](#output\_worker\_group\_ids) | OKE worker pool OCIDs |
| <a name="output_worker_pools_active"></a> [worker\_groups\_active](#output\_worker\_groups\_active) | OKE cluster CA certificate |
<!-- END_TF_DOCS -->