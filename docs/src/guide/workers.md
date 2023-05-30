# Workers

## General
The `worker_pools` input defines worker node configuration for the cluster.

Many of the global configuration values below may be overridden on each pool definition or omitted for defaults, with the `worker_` or `worker_pool_` variable prefix removed, e.g. `worker_image_id` overridden with `image_id`.

## Mode

The `mode` parameter controls the type of resources provisioned in OCI for OKE worker nodes.

**NOTE:** The only `mode` value currently supported is `node-pool`.

### OKE-managed

#### `mode = "node-pool"`

A standard OKE-managed pool of worker nodes with enhanced feature support:
* [oci_containerengine_node_pool](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool)
* [Modifying Node Pool and Worker Node Properties](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengmodifyingnodepool.htm)
* [Adding and Removing Node Pools](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengscalingclusters.htm)

### Self-managed

**NOTE:** Pending availability; contact us for more information.

#### `mode = "instance"`

A set of self-managed instances for custom user-provisioned worker nodes not managed by an OCI pool, but individually by Terraform:
* [oci_core_instance](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

See also:
* [Creating an Instance](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/launchinginstance.htm)

#### `mode = "instance-pool"`

A self-managed instance pool for custom user-provisioned worker nodes:
* [oci_core_instance_configuration](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration)
* [oci_core_instance_pool](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_pool)

See also:
* [Using Instance Configurations and Instance Pools](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/instancemanagement.htm)

****
#### `mode = "cluster-network"`

A self-managed instance pool with Cluster Networks integration:
* [oci_core_instance_configuration](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration)
* [oci_core_cluster_network](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cluster_network)

See also:
* [Cluster Networks with Instance Pools](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/managingclusternetworks.htm#Managing_Cluster_Networks)
* [Large Clusters, Lowest Latency: Cluster Networking on Oracle Cloud Infrastructure](https://blogs.oracle.com/cloud-infrastructure/post/large-clusters-lowest-latency-cluster-networking-on-oracle-cloud-infrastructure)
* [First principles: Building a high-performance network in the public cloud](https://blogs.oracle.com/cloud-infrastructure/post/building-high-performance-network-in-the-cloud)
* [Running Applications on Oracle Cloud Using Cluster Networking](https://blogs.oracle.com/cloud-infrastructure/post/running-applications-on-oracle-cloud-using-cluster-networking)
****
## Cloud Init

Refer to [Cloud Init]().

## Image

The operating system image for worker nodes.

**Recommended base images:**
* [OKE Oracle Linux 7](https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-7.x)
* [OKE Oracle Linux 8](https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-8.x)

Refer to [OKE worker node images]() for more information.

## Scaling

There are two easy ways to add worker nodes to a cluster:
* Add entries to `worker_pools`.
* Increase the `size` of a `worker_pools` entry.

Worker pools can be added and removed, their size and boot volume size can be updated. After each change, run `terraform apply`.

Scaling changes to the number and size of pools are immediate after changing the parameters and running `terraform apply`. The changes to boot volume size will only be effective in newly created nodes _after_ the change is completed.

## Autoscaling

See [Extensions/Cluster Autoscaler]().

## Storage

Refer to [Storage](./storage.md).

## Draining

**NOTE:** TODO
