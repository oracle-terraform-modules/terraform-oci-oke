# Terraform Configuration options

[cidrsubnet]:http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
[helm]:https://www.helm.sh/
[networks]:https://erikberg.com/notes/networks.html
[ocilb]: https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/load-balancer-annotations.md
[terraform example]: ../terraform.tfvars.example
[topology]: ./topology.md

## Identity and access parameters
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| api_fingerprint                       | ssh api_fingerprint (required)                |                           |  None                 |
| api_private_key_path                  | path to api private key (required)            |                           |  None                 |
| compartment_name                      | OCI compartment name (required)               |                           |  None                 |     
| compartment_ocid                      | OCI compartment ocid (required)               |                           |  None                 |     
| tenancy_ocid                          | OCI tenancy ocid (required)                   |                           |  None                 |
| user_ocid                             | OCI user ocid (required)                      |                           |  None                 |

## SSH Keys
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| ssh_private_key_path                  | path to ssh private key (required)            |                           |  None                 |
| ssh_public_key_path                   | path to ssh public key (required)             |                           |  None                 |

## General OCI
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| label_prefix                          | a prefix to be prepended to the name of resources   |   e.g. dev, test, prod   |   oke            |
| region                                | OCI region where to provision (required)      | ap-seoul-1, ap-tokyo-1, eu-frankfurt-1, us-ashburn-1, uk-london-1, us-phoenix-1, ca-toronto-1 |   us-phoenix-1   |

## Networking
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| newbits                               | The difference between the VCN's netmask and the desired subnets mask. This translates into the newbits parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][networks] documentation.   |   |   See [terraform.tfvars.example][terraform example]   |
| subnets                               | Defines the boundaries of the subnets. This translates into the netnum parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][networks] documentation.   | See [terraform.tfvars.example][terraform example]   | See [terraform.tfvars.example][terraform example]   |
| vcn_cidr                              | VCN's CIDR                                    |                           | 10.0.0.0/16           |
| vcn_dns_name                          | VCN's DNS name                                |                           |  oke                  |
| vcn_name                              | VCN's name in the OCI Console                 |                           |  oke vcn              |
| create_nat_gateway                    | Whether to create a NAT gateway. Required for private worker mode         |  true/false        |  true   |
| nat_gateway_name                      | NAT gateway name                              |                           |  nat                  | 
| create_service_gateway                | Whether to create a Service Gateway for object storage. | true/false      |  true                |
| service_gateway_name                  | Service Gateway name                          |                           |  sg                   |

## Bastion
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| bastion_shape                         | The shape of the bastion instance that will be provisioned.  |            | VM.Standard2.1        |
| create_bastion                        | Whether to create the bastion                 |   true/false              | true                  |
| bastion_access                        | CIDR block from where the bastion can be sshed into. Default is "ANYWHERE" and equivalent to "0.0.0.0/0"   | CIDR Block in the form of "XXX.XXX.XXX.XXX/X" for which ssh access would be allowed and everywhere else restricted   | "ANYWHERE" |
| enable_instance_principal             | whether to enable instance_principal on bastion. Ensure the user_ocid is part of administrators group in order to use this. |   true/false            |  false                 |
| image_ocid                            | The ocid of the image to use for the bastion instance. Tested with Oracle Linux 7.x and Ubuntu 18.04. Should work with Oracle Linux 6.x and CentOS 6.x and 7.x too. (Optional)       |               |  NONE              |
| image_operating_system                         | The Operating System image to be used to provision the bastion  |            | Oracle Linux      |
| image_operating_system_version                        | The version of the Operating System to be used to provision the bastion. Matching versions of available operating systems can be found here: https://docs.cloud.oracle.com/iaas/images/  |            | 7.6      |
| availability_domains                  | Where to provision bastion instance, worker and load balancer subnets.  |    | See [terraform.tfvars.example][terraform example]    |



## OKE Configuration
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| allow_node_port_access  | When workers are deployed in public mode, whether to allow NodePort access | true/false   | false |
| allow_worker_ssh_access | When to allow ssh access to worker nodes. All ssh access will be through the bastion host | true/false   | false |
| cluster_name                          | The name of the OKE cluster as it will appear in the OCI Console.                        |        |  oke     |
| dashboard_enabled                     | Whether to create the default Kubernetes dashboard.                                      | true/false |   true      |
| kubernetes_version                    | The version of Kubernetes to provision. This is based on the available versions in OKE. To provision a specific version, choose from available versions and override the 'LATEST' value. |   LATEST, v1.10.11, v1.11.9, v1.12.7     |       LATEST    |
| node_pools                            | Number of node pools to create. Terraform will use this number in conjunction with the node_pool_name_prefix to create the name of the node pools.                                              |               |    1       |
| node_pool_name_prefix                 | The prefix of the node pool.                                           |                 |   np                     |
| node_pool_image_id                    | OCID of custom image to use for worker node. Use either node_pool_image_id __or__ node_pool_image_operating_system   |       |   NONE           |
| node_pool_image_operating_system      | The image Operating System for the worker nodes.                       |  Oracle Linux   |   Oracle Linux           |
| node_pool_image_operating_system_version      | The version of image Operating System to use for the worker nodes. |  7.6        |   7.6                    |
| node_pool_node_shape                  | The shape for the worker nodes.                                        |                 |           VM.Standard2.1 |
| node_pool_quantity_per_subnet         | Number of worker nodes by worker subnets.                                              |               |         1  |
| nodepool_topology                     | Whether to make the node pool span 2 or 3 subnets (maps to AD). This parameter is only taken into consideration **only** in 3-AD regions. Acceptable and tested values are 2 or 3 only. The total number of worker nodes created is effectively obtained by this formula: nodepool_topology x  node_pools x  node_pool_quantity_per_subnet. In single AD, the number of worker nodes created = node_pools x the greater of (2,node_pool_quantity_per_subnet)   |    2 or 3           |     3      |
| pods_cidr                             | The CIDR for the Kubernetes POD network.                               |                 |    10.244.0.0/16         |
| services_cidr                         | The CIDR for the Kubernetes services network.                          |                 | 10.96.0.0/16             |
| tiller_enabled                        | Whether to install the server side of [Helm][helm] in the OKE cluster. |  true/false                  |   true      |
| worker_mode                           | Whether worker nodes should be public or private. Private requires NAT gateway.  | public/private |       public    |

## OKE Load Balancers
| Option                                | Description                                   | Values                    | Default               |     
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| load_balancer_subnet_type    | Type of load balancer subnets to create   |   both, internal, public   |  public |
| preferred_lb_ads   | Preferred Availability Domains for Load Balancers in list format. Maps to the created Load Balancer subnets in the availability_domain parameter. Choose 2 from ad1, ad2, ad3  | ["ad1", "ad2"[]  |   ["ad1", "ad2"]   | 
| preferred_load_balancer_subnets    | Preferred load balancer subnets that OKE will automatically choose when creating a load balancer. If 'public' is chosen, the value for load_balancer_subnet_type must be either 'public' or 'both'. If 'private' is chosen, the value for load_balancer_subnet_type must be either 'internal' or 'both'. Use service annotations (oci-load-balancer-internal) and set the value to true to create internal load balancers. Refer to [OCI Load Balancer annotations][ocilb]   |   internal, public   |  public |

## OCIR
| Option                                | Description                                   | Values                    | Default               |     
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| create_auth_token                     | Whether to create an auth token. Set to 'true' so OCIR can be used   | true/false   | false        |
| email_address                         | Email address of the username. Required if create_auth_token is set to true  | string       |  None       |
| tenancy_name                          | OCI tenancy name. Note this is different from tenancy ocid. Required if create_auth_token is set to true     | string  |  None       |
| username                              | OCI username. Note this is different from user_ocid. It's a username that can login to the selected tenancy. Required if create_auth_token is set to true  |   string                        |  None                 |

## Helm
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| add_incubator_repo  |   Whether to add the incubtator repo to the bastion's local helm repo   |  true/false |  false |
| add_jetstack_repo   |   Whether to add the jetstack repo to the bastion's local helm repo. Required for cert-manager   |  true/false |  false |
| install_helm                          | Whether to install helm on the bastion instance. You need to enable at least 1 of the bastion instances under the 'availability_domains' parameter.                                            |                true/false | false           |
| helm_version                          | The version of helm to install.                                              |               |          2.14.1 |


## Network Policy (Calico)
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| install_calico                        | Whether to install calico as network policy                   |     true/false       |  false                 |
| calico_version                        | Version of calico as network policy                           |                      |  3.6                   |
