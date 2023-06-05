## Configuration

:uri-repo: https://github.com/oracle-terraform-modules/terraform-oci-oke

:uri-rel-file-base: link:{uri-repo}/blob/main
:uri-rel-tree-base: link:{uri-repo}/tree/main
:uri-docs: {uri-rel-file-base}/docs

:uri-changelog: {uri-rel-file-base}/CHANGELOG.adoc
:uri-contribute: {uri-rel-file-base}/CONTRIBUTING.adoc
:uri-contributors: {uri-rel-file-base}/CONTRIBUTORS.adoc
:uri-instructions: {uri-docs}/instructions.adoc
:uri-license: {uri-rel-file-base}/LICENSE.txt
:uri-kubernetes: https://kubernetes.io/
:uri-kubernetes-hpa: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
:uri-metrics-server: https://github.com/kubernetes-incubator/metrics-server
:uri-networks-subnets-cidr: https://erikberg.com/notes/networks.html
:uri-oci-authtoken: https://docs.cloud.oracle.com/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm
:uri-oci-secret: https://docs.cloud.oracle.com/en-us/iaas/Content/KeyManagement/Tasks/managingsecrets.htm
:uri-oci: https://cloud.oracle.com/cloud-infrastructure
:uri-oci-documentation: https://docs.cloud.oracle.com/iaas/Content/home.htm
:uri-oci-instance-principal: https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm
:uri-oci-kms: https://docs.cloud.oracle.com/iaas/Content/KeyManagement/Concepts/keyoverview.htm
:uri-oci-loadbalancer-annotations: https://github.com/oracle/oci-cloud-controller-manager/blob/main/docs/load-balancer-annotations.md
:uri-oci-region: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm
:uri-oci-ocir: https://docs.cloud.oracle.com/iaas/Content/Registry/Concepts/registryoverview.htm
:uri-oke: https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengoverview.htm
:uri-oracle: https://www.oracle.com
:uri-prereqs: {uri-docs}/prerequisites.adoc
:uri-quickstart: {uri-docs}/quickstart.adoc
:uri-oci-tags-overview: https://docs.oracle.com/en-us/iaas/Content/Tagging/Concepts/taggingoverview.htm
:uri-oci-tags-management: https://docs.oracle.com/en-us/iaas/Content/Tagging/Tasks/managingtagsandtagnamespaces.htm#workdefined

:uri-terraform: https://www.terraform.io
:uri-terraform-cidrsubnet-desconstructed: http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
:uri-terraform-oci: https://www.terraform.io/docs/providers/oci/index.html
:uri-terraform-oke-sample: https://github.com/terraform-providers/terraform-provider-oci/tree/master/examples/container_engine
:uri-topology: {uri-docs}/topology.adoc
:uri-cloudinit: {uri-docs}/cloudinit.adoc

== Assumptions

This section assumes you have completed all the {uri-prereqs}[Prerequisites].

== Configure Identity

Enter the values for the following parameters in the terraform.tfvars file:

* api_fingerprint
* api_private_key_path
* compartment_id
* tenancy_id
* user_id

e.g.

```
api_fingerprint = "1a:bc:23:45:6d:78:e9:f0:gh:ij:kl:m1:23:no:4p:5q"
```

Alternatively, you can also specify these using Terraform environment variables by prepending TF_variable_name e.g.

```
export TF_api_fingerprint = "1a:bc:23:45:6d:78:e9:f0:gh:ij:kl:m1:23:no:4p:5q"
```

You would have obtained your values when doing the {uri-prereqs}[Prerequisites].

{uri-terraform-options}#identity-and-access[Reference]



### Configure OCI parameters

The 3 OCI parameters here mainly concern:

* `compartment_id`: is the compartment where all the resources will be created in
* `region`: this allows you to select the region where you want the OKE cluster deployed

e.g.

```
compartment_id = "compartment_id = "ocid1.compartment...."
home_region = "us-phoenix-1"
region = "ap-sydney-1"
```

Regions must have exactly 2 entries as above:

* home_region: is the tenancy's home region. This may be different from the region where you want to create OKE.
* region: is the actual region where you want to create the OKE cluster.

The list of regions can be found {uri-oci-region}[here].

{uri-terraform-options}#general-oci[Reference]

== Configure OKE Load Balancer

The OKE Load Balancer parameters concern mainly the following:

. the type of load balancer (public/internal)
. the list of destination ports to allow for public ingress

Even if you set the load balancer subnets to be internal, you still need to set the correct {uri-oci-loadbalancer-annotations}[annotations] when creating internal load balancers. Just setting the subnet to be private is *_not_* sufficient.

Refer to {uri-topology}[topology] for more thorough examples.

{uri-terraform-options}#oke-load-balancers[Reference]


