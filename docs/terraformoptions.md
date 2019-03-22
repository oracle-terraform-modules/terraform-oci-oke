# Terraform Configuration options

[cidrsubnet]:http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
[helm]:https://www.helm.sh/
[networks]:https://erikberg.com/notes/networks.html
[terraform example]: ../terraform.tfvars.example
[topology]: ./topology.md

## Basic OCI Configurations
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| tenancy_ocid                          | OCI tenancy ocid (required)                   |                           |  None                 |
| user_ocid                             | OCI user ocid (required)                      |                           |  None                 |
| compartment_ocid                      | OCI compartment ocid (required)               |                           |  None                 |     
| compartment_name                      | OCI compartment name (required)               |                           |  None                 |     
| api_fingerprint                       | ssh api_fingerprint (required)                |                           |  None                 |
| api_private_key_path                  | path to api private key (required)            |                           |  None                 |
| ssh_private_key_path                  | path to ssh private key (required)            |                           |  None                 |
| ssh_public_key_path                   | path to ssh public key (required)             |                           |  None                 |     | enable_instance_principal             | whether to enable instance_principal on bastion. Ensure the user_ocid is part of administrators group in order to use this. |   true/false            |  false                 |  
| region                                | OCI region where to provision (required)      | eu-frankfurt-1, us-ashburn-1, uk-london-1, us-phoenix-1, ca-toronto-1 | us-ashburn-1 |
| label_prefix                          | a prefix to be prepended to the name of resources   |   e.g. dev, test, prod   |   oke            |
| vcn_dns_name                          | VCN's DNS name                                |                           |  ocioke               |
| vcn_cidr                              | VCN's CIDR                                    |                           | 10.0.0.0/16           |
| vcn_name                              | VCN's name in the OCI Console                 |                           |  oke vcn              |
| newbits                               | The difference between the VCN's netmask and the desired subnets mask. This translates into the newbits parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][networks] documentation.                                              |               |   8        |
| subnets                               | Defines the boundaries of the subnets. This translates into the netnum parameter in the cidrsubnet Terraform function. [In-depth explanation][cidrsubnet]. Related [networks, subnets and cidr][networks] documentation.                                            | See [terraform.tfvars.example][terraform example]                |    See [terraform.tfvars.example][terraform example]        |
| imageocids                            | The ocids of the images to use for the bastion instances. Tested with Oracle Linux 7.x. Should work with Oracle Linux 6.x and CentOS 6.x and 7.x too       |               |  See [terraform.tfvars.example][terraform example]              |
| bastion_shape                         | The shape of the bastion instance that will be provisioned.  |               | VM.Standard2.1          |
| availability_domains                                    | Where to provision bastion instances, worker and load balancer subnets.  |    | See [terraform.tfvars.example][terraform example]    |
| label_prefix                          | A prefix that's prepended to created resources  |        |  oke             |

## NAT
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| create_nat_gateway                    | Whether to create a NAT gateway. Required for private worker nodes        |     true/false       |  false                 |
| nat_gateway_name                      | NAT gateway name                              |                           |  nat                  | 

## Service Gateway
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| create_service_gateway                | Whether to create a Service Gateway for object storage. | true/false      |  false                |
| service_gateway_name                  | Service Gateway name                          |                           |  sg                   | 

## OKE Configuration
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| kubernetes_version                    | The version of Kubernetes to provision. This is based on the available versions in OKE.  |   1.10.11, 1.11.8, 1.12.6     |       1.12.6    |
| worker_mode                           | Whether worker nodes should be public or private. Private requires NAT gateway.  | public/private |       public    |
| cluster_name                          | The name of the OKE cluster as it will appear in the OCI Console.                        |        |  okecluster     |
| dashboard_enabled                     | Whether to create the default Kubernetes dashboard.                                      | true/false |   true      |
| tiller_enabled                        | Whether to install the server side of [Helm][helm] in the OKE cluster. |  true/false                  |   true      |
| pods_cidr                             | The CIDR for the Kubernetes POD network.                               |                 |    10.244.0.0/16         |
| services_cidr                         | The CIDR for the Kubernetes services network.                          |                 | 10.96.0.0/16             |
| node_pool_name_prefix                 | The prefix of the node pool.                                           |                 |   np                     |
| node_pool_node_image_name             | The image name for the worker nodes.                                   |  Oracle-Linux-7.5 |       Oracle-Linux-7.5 |
| node_pool_node_shape                  | The shape for the worker nodes.                                        |                 |           VM.Standard2.1 |
| node_pool_quantity_per_subnet         | Number of worker nodes by worker subnets.                                              |               |         1  |
| node_pools                            | Number of node pools to create. Terraform will use this number in conjunction with the node_pool_name_prefix to create the name of the node pools.                                              |               |    1       |
| nodepool_topology                     | Whether to make the node pool span 2 or 3 subnets (ergo AD). Acceptable and tested values are 2 or 3 only. The total number of worker nodes created is effectively obtained by this formula: nodepool_topology x  node_pools x  node_pool_quantity_per_subnet.                                            |    2 or 3           |     3      |

## Network Policy (Calico)
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| install_calico                        | Whether to install calico as network policy                   |     true/false       |  false                 |
| calico_version                        | Version of calico as network policy                           |                      |  3.6                   | 

## OCIR
| Option                                | Description                                   | Values                    | Default               |     | -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| create_auth_token                    | Whether to create an auth token. Set to 'true' so OCIR can be used  | true/false        |       true    |
| tenancy_name                          | OCI tenancy name (required). Note this is different from tenancy ocid     | string                       |  None    |
| username                              | OCI username (required). Note this is different from user_ocid. It's a username that can login to the selected tenancy                      |                           |  None                 |
| email_address                         | Email address (required)  of the above username                           | string                       |  None    |


## Addons
| Option                                | Description                                   | Values                    | Default               | 
| -----------------------------------   | -------------------------------------------   | ------------              | -------------------   |
| install_helm                          | Whether to install helm on the bastion instance. You need to enable at least 1 of the bastion instances under the 'availability_domains' parameter.                                            |                true/false | false           |
| helm_version                          | The version of helm to install.                                              |               |          2.13.0 |
| install_ksonnet                          | Whether to install ksonnet on the bastion instance. You need to enable at least 1 of the bastion instances under the 'availability_domains' parameter.                                            |                true/false | false           |
| ksonnet_version                          | The version of ksonnet to install.                                              |               |          0.13.1 |