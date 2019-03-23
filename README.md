[cidrsubnet]:http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
[calico]: https://www.projectcalico.org/
[configure oci]: https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/terraformgetstarted.htm?tocpath=Developer%20Tools%20%7CTerraform%20Provider%7C_____1
[example network resource configuration]:https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengnetworkconfigexample.htm
[helm]:https://www.helm.sh/
[instructions]: ./docs/instructions.md
[ksonnet]: https://ksonnet.io/
[kubernetes]: https://kubernetes.io/
[networks]:https://erikberg.com/notes/networks.html
[oci]: https://cloud.oracle.com/cloud-infrastructure
[oke]: https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengoverview.htm
[terraform]: https://www.terraform.io
[terraform example]: ./terraform.tfvars.example
[terraform options]: ./docs/terraformoptions.md
[terraform oke sample]: https://github.com/oracle/terraform-provider-oci/tree/master/docs/examples/container_engine
[topology]: ./docs/topology.md

# Terraform Module for [Oracle Container Engine][oke]

## About

The Terraform OKE Module Installer for [Oracle Cloud Infrastructure][oci] provides a Terraform module that provisions the necessary resources for [Oracle Container Engine][oke]. This is based on the [Example Network Resource Configuration][example network resource configuration].
It leverages the baseoci project to create the basic infrastructure (VCNs, subnets, security lists etc), cluster and node pools. 

## Features

- Configurable subnet masks and sizes. This helps you:
    - limit your blast radius
    - avoid the overlapping subnet problem, especially if you need to make a hybrid deployment
    - plan your scalability, HA and failover capabilities
- Optional co-located and pre-configured public bastion instances across all 3 ADs. This helps execute kubectl commands faster. The bastion instance has the following configurable features:
    - oci-cli installed, upgraded and pre-configured
    - kubectl installed and pre-configured
    - kubeconfig generation
    - [helm][helm] installed and pre-configured (see [helm][instructions])
    - convenient output of how to access the bastion instances
    - choice of AD location for the bastion instance(s) to avoid problems with service limits/shapes, particularly when using trial accounts
- Automatic creation of [OKE pre-requisites][example network resource configuration]:
    - 3 worker subnets with their corresponding security lists, ingress and egress rules
    - 3 load balancer subnets with their corresponding security lists, ingress and egress rules
    - Possiblity to expand by adding more subnets
- NAT and public/private worker nodes
    - Possiblity of creating NAT gateway
    - Choice of specifying whether worker nodes can be public or private
- Automatic creation of an OKE cluster with the following configurable options:
    - cluster name
    - [Kubernetes][kubernetes] version
    - Kubernetes addons such as dashboard and helm (tiller)
    - pods and services cidr
- Automatic node pool creation with the following configurable options:
    - number of node pools to be created
    - choice of node pool [topology][topology] i.e. whether to make a node pool span 2 or 3 subnets (effectively make a nodepool span 2 or 3 ADs within a region)
    - number of worker nodes per subnets
    - fair distribution of node pools across the ADs in the region when choosing [2 subnets topology][topology] so that node pools are not concentrated in some ADs only
    - programmable node pool prefix
    - configurable worker node shape
- Optional K8s Network Policy:
    - Installation of [calico][calico] for network policy  
- kubeconfig:
    - automatic generation of kubeconfig on the bastion instances and set to default location (/home/opc/.kube/config) so there's no need to explicitly set KUBECONFIG variable
    - automatic generation of kubeconfig locally under the generated folder
- Automatic OCI Registry configuration:
    - Auth token created and saved. It can also be retrieved for later use
    - Kubernetes Secret automatically created in default namespace to allow pulling images from OCIR 
- [helm][helm]:
    - optional installation and configuration of helm on the bastion instances
    - choice of helm version
    - upgrade of the running tiller on the cluster
- [ksonnet][ksonnet]:
    - optional installation and configuration of ksonnet on the bastion instances
    - choice of ksonnet version

## Pre-reqs

1. Download and install [Terraform][terraform] (v0.11+).
2. Download and install the [OCI Terraform Provider][oci provider]. You need at least v3.8.0 to provision OKE, NAT Gateway.
3. [Configure your OCI account to use Terraform][configure oci]

Detailed instructions can be found [here][instructions].

## Environment variables

Ensure you set proxy environment variables if you're running behind a proxy

```
$ export http_proxy=http://<address_of_your_office_proxy>.com:80/
$ export https_proxy=http://<address_of_your_office_proxy>:80/
```
Detailed instructions, including proxy locations can be found [here][instructions].

## Quickstart

```
$ git clone <thisrepo>.git tfoke
$ cd tfoke 
$ cp terraform.tfvars.example terraform.tfvars
```
* Set mandatory variables tenancy_ocid, user_ocid, compartment_ocid, api_fingerprint in terraform.tfvars

* Override other variables vcn_name, vcn_dns_name, shapes etc in terraform.tfvars. See the [terraform.tfvars.example][terraform example].

Detailed instructions can be found [here][instructions].

### Deploy OKE

Initialize Terraform:
```
$ terraform init
```

View what Terraform plans do before actually doing it:
```
$ terraform plan
```

Compare what will be provisioned in terms of compute instances/shapes (bastion, worker nodes) vs what is available under your service limits of the account in your region and the ADs and modify accordingly. Make sure you read and understand the impact of OKE Parameters. The algorithm is explained below and on the [topology page][topology]. In particular, pay attention to these variables node_pool_topology, node_pools, node_pool_quantity_per_subnet and node_pool_node_shape.

Create oke resources, cluster:
```
$ terraform apply
```

See [Terraform Configuration Options][terraform options] and [Detailed Instructions][instructions]

## Related Docs

- [Example VCN Configuration][example network resource configuration]
- [OKE][oke]
- [Networks, Subnets and CIDR][networks]
- [Terraform cidrsubnet Deconstructed][cidrsubnet]

## Acknowledgement
- Code derived and adapted from [Terraform OKE Sample][terraform oke sample]

- Folks who contributed with code, feedback, ideas, testing etc:
    - Stephen Cross
    - Cameron Senese
    - Jang Whan
    - Mike Raab
    - Jon Reeve
    - Craig Carl
    - Arjav Desai
    - Patrick Galbraith
    - Jeevan Joseph
    - Manish Kapur
    - Jeet Jagasia
    - Karsten Terp-Nielsen
    - Rajesh Chawla
    - Erno Venalainen
    - Mika Rinne
    - Kristen Jacobs
    - Tim Sheppard
