# Workers / Mode: Compute Clusters

<p>

Create self-managed HPC Compute Clusters.

A compute cluster is a group of high performance computing (HPC), GPU, or optimized instances that are connected with a high-bandwidth, ultra low-latency network.

[Supported shapes](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/compute-clusters.htm#compute-cluster-shapes):
* BM.GPU.A100-v2.8
* BM.GPU.H100.8
* BM.GPU4.8
* BM.HPC2.36
* BM.Optimized3.36

Configured with `mode = "compute-cluster"` on a `worker_pools` entry, or with `worker_pool_mode = "compute-cluster"` to use as the default for all pools unless otherwise specified.
</p>

Compute clusters shared by multiple worker groups must be created using the variable `worker_compute_clusters` and should be referenced by the key in the `compute_cluster` attribute of the worker group. 
If the `worker_compute_clusters` is not specified, the module will create a compute cluster per each worker group.

## Usage

```javascript
{{#include ../../../examples/workers/vars-workers-computecluster.auto.tfvars:4:}}
```

Instance agent configuration:
```javascript
{{#include ../../../examples/workers/vars-workers-agent.auto.tfvars:4:}}
```

## References
* [Compute Clusters](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/compute-clusters.htm)
* [Large Clusters, Lowest Latency: Cluster Networking on Oracle Cloud Infrastructure](https://blogs.oracle.com/cloud-infrastructure/post/large-clusters-lowest-latency-cluster-networking-on-oracle-cloud-infrastructure)
* [First principles: Building a high-performance network in the public cloud](https://blogs.oracle.com/cloud-infrastructure/post/building-high-performance-network-in-the-cloud)
* [Running Applications on Oracle Cloud Using Cluster Networking](https://blogs.oracle.com/cloud-infrastructure/post/running-applications-on-oracle-cloud-using-cluster-networking)
