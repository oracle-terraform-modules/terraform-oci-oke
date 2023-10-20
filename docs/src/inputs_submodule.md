# Inputs

Sub-modules currently use a sparse definition of inputs required from the root:

## Identity Access Management (IAM)
<!-- BEGIN_TF_IAM -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_iam_autoscaler_policy"></a> [create\_iam\_autoscaler\_policy](#input\_create\_iam\_autoscaler\_policy)| n/a|  bool|  n/a|  yes|
| <a name="input_create_iam_defined_tags"></a> [create\_iam\_defined\_tags](#input\_create\_iam\_defined\_tags)| Tags|  bool|  n/a|  yes|
| <a name="input_create_iam_kms_policy"></a> [create\_iam\_kms\_policy](#input\_create\_iam\_kms\_policy)| n/a|  bool|  n/a|  yes|
| <a name="input_create_iam_operator_policy"></a> [create\_iam\_operator\_policy](#input\_create\_iam\_operator\_policy)| n/a|  bool|  n/a|  yes|
| <a name="input_create_iam_resources"></a> [create\_iam\_resources](#input\_create\_iam\_resources)| n/a|  bool|  n/a|  yes|
| <a name="input_create_iam_tag_namespace"></a> [create\_iam\_tag\_namespace](#input\_create\_iam\_tag\_namespace)| n/a|  bool|  n/a|  yes|
| <a name="input_create_iam_worker_policy"></a> [create\_iam\_worker\_policy](#input\_create\_iam\_worker\_policy)| n/a|  bool|  n/a|  yes|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| n/a|  bool|  n/a|  yes|
| <a name="input_autoscaler_compartments"></a> [autoscaler\_compartments](#input\_autoscaler\_compartments)| Policy|  list(string)|  n/a|  yes|
| <a name="input_worker_compartments"></a> [worker\_compartments](#input\_worker\_compartments)| n/a|  list(string)|  n/a|  yes|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id)| Common|  string|  n/a|  yes|
| <a name="input_cluster_kms_key_id"></a> [cluster\_kms\_key\_id](#input\_cluster\_kms\_key\_id)| KMS|  string|  n/a|  yes|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| n/a|  string|  n/a|  yes|
| <a name="input_operator_volume_kms_key_id"></a> [operator\_volume\_kms\_key\_id](#input\_operator\_volume\_kms\_key\_id)| n/a|  string|  n/a|  yes|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| n/a|  string|  n/a|  yes|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| n/a|  string|  n/a|  yes|
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id)| n/a|  string|  n/a|  yes|
| <a name="input_worker_volume_kms_key_id"></a> [worker\_volume\_kms\_key\_id](#input\_worker\_volume\_kms\_key\_id)| n/a|  string|  n/a|  yes|

<!-- END_TF_IAM -->

## Network
<!-- BEGIN_TF_NETWORK -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_rules_internal_lb"></a> [allow\_rules\_internal\_lb](#input\_allow\_rules\_internal\_lb)| n/a|  any|  n/a|  yes|
| <a name="input_allow_rules_public_lb"></a> [allow\_rules\_public\_lb](#input\_allow\_rules\_public\_lb)| n/a|  any|  n/a|  yes|
| <a name="input_drg_attachments"></a> [drg\_attachments](#input\_drg\_attachments)| n/a|  any|  n/a|  yes|
| <a name="input_allow_bastion_cluster_access"></a> [allow\_bastion\_cluster\_access](#input\_allow\_bastion\_cluster\_access)| n/a|  bool|  n/a|  yes|
| <a name="input_allow_node_port_access"></a> [allow\_node\_port\_access](#input\_allow\_node\_port\_access)| Network|  bool|  n/a|  yes|
| <a name="input_allow_pod_internet_access"></a> [allow\_pod\_internet\_access](#input\_allow\_pod\_internet\_access)| n/a|  bool|  n/a|  yes|
| <a name="input_allow_worker_internet_access"></a> [allow\_worker\_internet\_access](#input\_allow\_worker\_internet\_access)| n/a|  bool|  n/a|  yes|
| <a name="input_allow_worker_ssh_access"></a> [allow\_worker\_ssh\_access](#input\_allow\_worker\_ssh\_access)| n/a|  bool|  n/a|  yes|
| <a name="input_assign_dns"></a> [assign\_dns](#input\_assign\_dns)| n/a|  bool|  n/a|  yes|
| <a name="input_bastion_is_public"></a> [bastion\_is\_public](#input\_bastion\_is\_public)| n/a|  bool|  n/a|  yes|
| <a name="input_control_plane_is_public"></a> [control\_plane\_is\_public](#input\_control\_plane\_is\_public)| n/a|  bool|  n/a|  yes|
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion)| n/a|  bool|  n/a|  yes|
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster)| n/a|  bool|  n/a|  yes|
| <a name="input_create_operator"></a> [create\_operator](#input\_create\_operator)| n/a|  bool|  n/a|  yes|
| <a name="input_enable_waf"></a> [enable\_waf](#input\_enable\_waf)| n/a|  bool|  n/a|  yes|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| n/a|  bool|  n/a|  yes|
| <a name="input_worker_is_public"></a> [worker\_is\_public](#input\_worker\_is\_public)| n/a|  bool|  n/a|  yes|
| <a name="input_vcn_cidrs"></a> [vcn\_cidrs](#input\_vcn\_cidrs)| n/a|  list(string)|  n/a|  yes|
| <a name="input_subnets"></a> [subnets](#input\_subnets)| n/a|  map(object({<br>    create    = optional(string)<br>    id        = optional(string)<br>    newbits   = optional(string)<br>    netnum    = optional(string)<br>    cidr      = optional(string)<br>    dns\_label = optional(string)<br>  }))|  n/a|  yes|
| <a name="input_nsgs"></a> [nsgs](#input\_nsgs)| n/a|  map(object({<br>    create = optional(string)<br>    id     = optional(string)<br>  }))|  n/a|  yes|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags)| Tags|  map(string)|  n/a|  yes|
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_bastion_allowed_cidrs"></a> [bastion\_allowed\_cidrs](#input\_bastion\_allowed\_cidrs)| n/a|  set(string)|  n/a|  yes|
| <a name="input_control_plane_allowed_cidrs"></a> [control\_plane\_allowed\_cidrs](#input\_control\_plane\_allowed\_cidrs)| n/a|  set(string)|  n/a|  yes|
| <a name="input_cni_type"></a> [cni\_type](#input\_cni\_type)| n/a|  string|  n/a|  yes|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| Common|  string|  n/a|  yes|
| <a name="input_ig_route_table_id"></a> [ig\_route\_table\_id](#input\_ig\_route\_table\_id)| n/a|  string|  n/a|  yes|
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers)| n/a|  string|  n/a|  yes|
| <a name="input_nat_route_table_id"></a> [nat\_route\_table\_id](#input\_nat\_route\_table\_id)| n/a|  string|  n/a|  yes|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| n/a|  string|  n/a|  yes|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| n/a|  string|  n/a|  yes|
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id)| n/a|  string|  n/a|  yes|

<!-- END_TF_NETWORK -->

## Bastion
<!-- BEGIN_TF_BASTION -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_dns"></a> [assign\_dns](#input\_assign\_dns)| Bastion|  bool|  n/a|  yes|
| <a name="input_is_public"></a> [is\_public](#input\_is\_public)| n/a|  bool|  n/a|  yes|
| <a name="input_upgrade"></a> [upgrade](#input\_upgrade)| n/a|  bool|  n/a|  yes|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| n/a|  bool|  n/a|  yes|
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids)| n/a|  list(string)|  n/a|  yes|
| <a name="input_shape"></a> [shape](#input\_shape)| n/a|  map(any)|  n/a|  yes|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags)| Tags|  map(string)|  n/a|  yes|
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain)| n/a|  string|  n/a|  yes|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| Common|  string|  n/a|  yes|
| <a name="input_image_id"></a> [image\_id](#input\_image\_id)| n/a|  string|  n/a|  yes|
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key)| n/a|  string|  n/a|  yes|
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key)| n/a|  string|  n/a|  yes|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| n/a|  string|  n/a|  yes|
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)| n/a|  string|  n/a|  yes|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| n/a|  string|  n/a|  yes|
| <a name="input_timezone"></a> [timezone](#input\_timezone)| n/a|  string|  n/a|  yes|
| <a name="input_user"></a> [user](#input\_user)| n/a|  string|  n/a|  yes|

<!-- END_TF_BASTION -->

## Cluster
<!-- BEGIN_TF_CLUSTER -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_is_public"></a> [control\_plane\_is\_public](#input\_control\_plane\_is\_public)| n/a|  bool|  n/a|  yes|
| <a name="input_use_signed_images"></a> [use\_signed\_images](#input\_use\_signed\_images)| n/a|  bool|  n/a|  yes|
| <a name="input_cluster_defined_tags"></a> [cluster\_defined\_tags](#input\_cluster\_defined\_tags)| Tagging|  map(string)|  n/a|  yes|
| <a name="input_cluster_freeform_tags"></a> [cluster\_freeform\_tags](#input\_cluster\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_persistent_volume_defined_tags"></a> [persistent\_volume\_defined\_tags](#input\_persistent\_volume\_defined\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_persistent_volume_freeform_tags"></a> [persistent\_volume\_freeform\_tags](#input\_persistent\_volume\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_service_lb_defined_tags"></a> [service\_lb\_defined\_tags](#input\_service\_lb\_defined\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_service_lb_freeform_tags"></a> [service\_lb\_freeform\_tags](#input\_service\_lb\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_control_plane_nsg_ids"></a> [control\_plane\_nsg\_ids](#input\_control\_plane\_nsg\_ids)| n/a|  set(string)|  n/a|  yes|
| <a name="input_image_signing_keys"></a> [image\_signing\_keys](#input\_image\_signing\_keys)| n/a|  set(string)|  n/a|  yes|
| <a name="input_cluster_kms_key_id"></a> [cluster\_kms\_key\_id](#input\_cluster\_kms\_key\_id)| Cluster|  string|  n/a|  yes|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)| n/a|  string|  n/a|  yes|
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type)| n/a|  string|  n/a|  yes|
| <a name="input_cni_type"></a> [cni\_type](#input\_cni\_type)| n/a|  string|  n/a|  yes|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| Common|  string|  n/a|  yes|
| <a name="input_control_plane_subnet_id"></a> [control\_plane\_subnet\_id](#input\_control\_plane\_subnet\_id)| n/a|  string|  n/a|  yes|
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version)| n/a|  string|  n/a|  yes|
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr)| n/a|  string|  n/a|  yes|
| <a name="input_service_lb_subnet_id"></a> [service\_lb\_subnet\_id](#input\_service\_lb\_subnet\_id)| n/a|  string|  n/a|  yes|
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr)| n/a|  string|  n/a|  yes|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| n/a|  string|  n/a|  yes|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| n/a|  string|  n/a|  yes|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| n/a|  string|  n/a|  yes|
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id)| n/a|  string|  n/a|  yes|

<!-- END_TF_CLUSTER -->

## Workers
<!-- BEGIN_TF_WORKERS -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_ids"></a> [image\_ids](#input\_image\_ids)| Map of images for filtering with image\_os and image\_os\_version.|  any|  {}|  no|
| <a name="input_worker_pools"></a> [worker\_pools](#input\_worker\_pools)| Tuple of OKE worker pools where each key maps to the OCID of an OCI resource, and value contains its definition.|  any|  {}|  no|
| <a name="input_assign_dns"></a> [assign\_dns](#input\_assign\_dns)| n/a|  bool|  n/a|  yes|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip)| n/a|  bool|  n/a|  yes|
| <a name="input_disable_default_cloud_init"></a> [disable\_default\_cloud\_init](#input\_disable\_default\_cloud\_init)| Whether to disable the default OKE cloud init and only use the cloud init explicitly passed to the worker pool in 'worker\_cloud\_init'.|  bool|  false|  no|
| <a name="input_pv_transit_encryption"></a> [pv\_transit\_encryption](#input\_pv\_transit\_encryption)| Whether to enable in-transit encryption for the data volume's paravirtualized attachment by default when unspecified on a pool.|  bool|  false|  no|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| Whether to apply defined tags to created resources for IAM policy and tracking.|  bool|  false|  no|
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init)| List of maps containing cloud init MIME part configuration for worker nodes. Merged with pool-specific definitions. See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html#part for expected schema of each element.|  list(map(string))|  []|  no|
| <a name="input_ad_numbers"></a> [ad\_numbers](#input\_ad\_numbers)| n/a|  list(number)|  n/a|  yes|
| <a name="input_pod_nsg_ids"></a> [pod\_nsg\_ids](#input\_pod\_nsg\_ids)| An additional list of network security group (NSG) IDs for pod security. Combined with 'pod\_nsg\_ids' specified on each pool.|  list(string)|  []|  no|
| <a name="input_worker_nsg_ids"></a> [worker\_nsg\_ids](#input\_worker\_nsg\_ids)| An additional list of network security group (NSG) IDs for node security. Combined with 'nsg\_ids' specified on each pool.|  list(string)|  []|  no|
| <a name="input_preemptible_config"></a> [preemptible\_config](#input\_preemptible\_config)| Default preemptible Compute configuration when unspecified on a pool. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengusingpreemptiblecapacity.htm>Preemptible Worker Nodes</a> for more information.|  map(any)|  {<br>  "enable": false,<br>  "is\_preserve\_boot\_volume": false<br>}|  no|
| <a name="input_shape"></a> [shape](#input\_shape)| Default shape of the created worker instance when unspecified on a pool.|  map(any)|  {<br>  "boot\_volume\_size": 50,<br>  "memory": 16,<br>  "ocpus": 2,<br>  "shape": "VM.Standard.E4.Flex"<br>}|  no|
| <a name="input_ad_numbers_to_names"></a> [ad\_numbers\_to\_names](#input\_ad\_numbers\_to\_names)| n/a|  map(string)|  n/a|  yes|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags)| Defined tags to be applied to created resources. Must already exist in the tenancy.|  map(string)|  {}|  no|
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags)| Freeform tags to be applied to created resources.|  map(string)|  {}|  no|
| <a name="input_node_labels"></a> [node\_labels](#input\_node\_labels)| Default worker node labels. Merged with labels defined on each pool.|  map(string)|  {}|  no|
| <a name="input_node_metadata"></a> [node\_metadata](#input\_node\_metadata)| Map of additional worker node instance metadata. Merged with metadata defined on each pool.|  map(string)|  {}|  no|
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node)| The default maximum number of pods to deploy per node when unspecified on a pool. Absolute maximum is 110. Ignored when when cni\_type != 'npn'.|  number|  31|  no|
| <a name="input_worker_pool_size"></a> [worker\_pool\_size](#input\_worker\_pool\_size)| Default size for worker pools when unspecified on a pool.|  number|  0|  no|
| <a name="input_agent_config"></a> [agent\_config](#input\_agent\_config)| Default agent\_config for self-managed worker pools created with mode: 'instance', 'instance-pool', or 'cluster-network'. See <a href=https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/InstanceAgentConfig for more information.|  object({<br>    are\_all\_plugins\_disabled = bool,<br>    is\_management\_disabled   = bool,<br>    is\_monitoring\_disabled   = bool,<br>    plugins\_config           = map(string),<br>  })|  null|  no|
| <a name="input_platform_config"></a> [platform\_config](#input\_platform\_config)| Default platform\_config for self-managed worker pools created with mode: 'instance', 'instance-pool', or 'cluster-network'. See <a href=https://docs.oracle.com/en-us/iaas/api/#/en/iaas/20160918/datatypes/PlatformConfig>PlatformConfig</a> for more information.|  object({<br>    type                                           = optional(string),<br>    are\_virtual\_instructions\_enabled               = optional(bool),<br>    is\_access\_control\_service\_enabled              = optional(bool),<br>    is\_input\_output\_memory\_management\_unit\_enabled = optional(bool),<br>    is\_measured\_boot\_enabled                       = optional(bool),<br>    is\_memory\_encryption\_enabled                   = optional(bool),<br>    is\_secure\_boot\_enabled                         = optional(bool),<br>    is\_symmetric\_multi\_threading\_enabled           = optional(bool),<br>    is\_trusted\_platform\_module\_enabled             = optional(bool),<br>    numa\_nodes\_per\_socket                          = optional(number),<br>    percentage\_of\_cores\_enabled                    = optional(bool),<br>  })|  null|  no|
| <a name="input_apiserver_private_host"></a> [apiserver\_private\_host](#input\_apiserver\_private\_host)| n/a|  string|  n/a|  yes|
| <a name="input_block_volume_type"></a> [block\_volume\_type](#input\_block\_volume\_type)| Default block volume attachment type for Instance Configurations when unspecified on a pool.|  string|  "paravirtualized"|  no|
| <a name="input_capacity_reservation_id"></a> [capacity\_reservation\_id](#input\_capacity\_reservation\_id)| The ID of the Compute capacity reservation the worker node will be launched under. See <a href=https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/reserve-capacity.htm>Capacity Reservations</a> for more information.|  string|  null|  no|
| <a name="input_cluster_ca_cert"></a> [cluster\_ca\_cert](#input\_cluster\_ca\_cert)| Base64+PEM-encoded cluster CA certificate for unmanaged instance pools. Determined automatically when 'create\_cluster' = true or 'cluster\_id' is provided.|  string|  null|  no|
| <a name="input_cluster_dns"></a> [cluster\_dns](#input\_cluster\_dns)| Cluster DNS resolver IP address. Determined automatically when not set (recommended).|  string|  null|  no|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id)| An existing OKE cluster OCID when `create_cluster = false`.|  string|  null|  no|
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type)| The cluster type. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm>Working with Enhanced Clusters and Basic Clusters</a> for more information.|  string|  "basic"|  no|
| <a name="input_cni_type"></a> [cni\_type](#input\_cni\_type)| The CNI for the cluster: 'flannel' or 'npn'. See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengpodnetworking.htm>Pod Networking</a>.|  string|  "flannel"|  no|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| The compartment id where resources will be created.|  string|  null|  no|
| <a name="input_image_id"></a> [image\_id](#input\_image\_id)| Default image for worker pools  when unspecified on a pool.|  string|  null|  no|
| <a name="input_image_os"></a> [image\_os](#input\_image\_os)| Default worker image operating system name when worker\_image\_type = 'oke' or 'platform' and unspecified on a pool.|  string|  "Oracle Linux"|  no|
| <a name="input_image_os_version"></a> [image\_os\_version](#input\_image\_os\_version)| Default worker image operating system version when worker\_image\_type = 'oke' or 'platform' and unspecified on a pool.|  string|  "8"|  no|
| <a name="input_image_type"></a> [image\_type](#input\_image\_type)| Whether to use a platform, OKE, or custom image for worker nodes by default when unspecified on a pool. When custom is set, the worker\_image\_id must be specified.|  string|  "oke"|  no|
| <a name="input_kubeproxy_mode"></a> [kubeproxy\_mode](#input\_kubeproxy\_mode)| The mode in which to run kube-proxy when unspecified on a pool.|  string|  "iptables"|  no|
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version)| The version of Kubernetes used for worker nodes.|  string|  "v1.26.2"|  no|
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id)| n/a|  string|  n/a|  yes|
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key)| The contents of the SSH public key file. Used to allow login for workers/bastion/operator with corresponding private key.|  string|  null|  no|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| Optional Terraform state\_id from an existing deployment of the module to re-use with created resources.|  string|  null|  no|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| The tag namespace for standard OKE defined tags.|  string|  "oke"|  no|
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id)| The tenancy id of the OCI Cloud Account in which to create the resources.|  string|  null|  no|
| <a name="input_timezone"></a> [timezone](#input\_timezone)| n/a|  string|  n/a|  yes|
| <a name="input_volume_kms_key_id"></a> [volume\_kms\_key\_id](#input\_volume\_kms\_key\_id)| The ID of the OCI KMS key to be used as the master encryption key for Boot Volume and Block Volume encryption by default when unspecified on a pool.|  string|  null|  no|
| <a name="input_worker_pool_mode"></a> [worker\_pool\_mode](#input\_worker\_pool\_mode)| Default management mode for workers when unspecified on a pool. Only 'node-pool' is currently supported.|  string|  "node-pool"|  no|
| <a name="input_worker_subnet_id"></a> [worker\_subnet\_id](#input\_worker\_subnet\_id)| n/a|  string|  n/a|  yes|

<!-- END_TF_WORKERS -->

## Operator
<!-- BEGIN_TF_OPERATOR -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_dns"></a> [assign\_dns](#input\_assign\_dns)| Operator|  bool|  n/a|  yes|
| <a name="input_install_helm"></a> [install\_helm](#input\_install\_helm)| n/a|  bool|  n/a|  yes|
| <a name="input_install_k9s"></a> [install\_k9s](#input\_install\_k9s)| n/a|  bool|  n/a|  yes|
| <a name="input_install_kubectx"></a> [install\_kubectx](#input\_install\_kubectx)| n/a|  bool|  n/a|  yes|
| <a name="input_pv_transit_encryption"></a> [pv\_transit\_encryption](#input\_pv\_transit\_encryption)| n/a|  bool|  n/a|  yes|
| <a name="input_upgrade"></a> [upgrade](#input\_upgrade)| n/a|  bool|  n/a|  yes|
| <a name="input_use_defined_tags"></a> [use\_defined\_tags](#input\_use\_defined\_tags)| n/a|  bool|  n/a|  yes|
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init)| n/a|  list(map(string))|  n/a|  yes|
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids)| n/a|  list(string)|  n/a|  yes|
| <a name="input_shape"></a> [shape](#input\_shape)| n/a|  map(any)|  n/a|  yes|
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags)| Tags|  map(string)|  n/a|  yes|
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags)| n/a|  map(string)|  n/a|  yes|
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain)| n/a|  string|  n/a|  yes|
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host)| Bastion (to await cloud-init completion)|  string|  n/a|  yes|
| <a name="input_bastion_user"></a> [bastion\_user](#input\_bastion\_user)| n/a|  string|  n/a|  yes|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id)| Common|  string|  n/a|  yes|
| <a name="input_image_id"></a> [image\_id](#input\_image\_id)| n/a|  string|  n/a|  yes|
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig)| n/a|  string|  n/a|  yes|
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version)| n/a|  string|  n/a|  yes|
| <a name="input_operator_image_os_version"></a> [operator\_image\_os\_version](#input\_operator\_image\_os\_version)| n/a|  string|  n/a|  yes|
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key)| n/a|  string|  n/a|  yes|
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key)| n/a|  string|  n/a|  yes|
| <a name="input_state_id"></a> [state\_id](#input\_state\_id)| n/a|  string|  n/a|  yes|
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)| n/a|  string|  n/a|  yes|
| <a name="input_tag_namespace"></a> [tag\_namespace](#input\_tag\_namespace)| n/a|  string|  n/a|  yes|
| <a name="input_timezone"></a> [timezone](#input\_timezone)| n/a|  string|  n/a|  yes|
| <a name="input_user"></a> [user](#input\_user)| n/a|  string|  n/a|  yes|
| <a name="input_volume_kms_key_id"></a> [volume\_kms\_key\_id](#input\_volume\_kms\_key\_id)| n/a|  string|  n/a|  yes|

<!-- END_TF_OPERATOR -->
