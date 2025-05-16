# Extensions: Standalone Cluster Autoscaler

**Note**: For the cluster autoscaler you should choose **only one** of the options:
- the stand-alone cluster-autoscaler deployment, using this extension
- the [cluster-autoscaler add-on](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons-configurationarguments.htm#contengconfiguringclusteraddons-configurationarguments_ClusterAutoscaler), using the [addons](./cluster_addons.md).

Deployed using the [cluster-autoscaler Helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler) with configuration from the `worker_pools` variable.

The module is using the `oke.oraclecloud.com/cluster_autoscaler` nodepool label to facilitate the understanding of how the Kubernetes cluster auto-scaler will interact with the node:
- `allowed` - cluster-autoscaler deployment will be allowed to run on the nodes with this label
- `managed` - cluster-autoscaler is managing this node (may terminate it if required)
- `disabled` - cluster-autoscaler will not run nor manage the node.

The following parameters may be added on each pool definition to enable management or scheduling of the cluster autoscaler:
* `allow_autoscaler`: Enable scheduling of the cluster autoscaler deployment on a pool by adding a node label matching the deployment's nodeSelector (`oke.oraclecloud.com/cluster_autoscaler: allowed`), and an OCI defined tag for use with [IAM tag-based policies](https://docs.oracle.com/en-us/iaas/Content/Tagging/Tasks/managingaccesswithtags.htm) granting access to the instances (`${var.tag_namespace}.cluster_autoscaler: allowed`).
* `autoscale`: Enable cluster autoscaler management of the pool by appending `--nodes <nodepool-ocid>` argument to the CMD of the `cluster-autoscaler` container. Nodes part of these nodepools will have the label `oke.oraclecloud.com/cluster_autoscaler: managed` and an OCI defined tag `${var.tag_namespace}.cluster_autoscaler: managed`. 
* `min_size`: Define the minimum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.
* `max_size`: Define the maximum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.

The cluster-autoscaler will manage the size of the nodepools with the attribute `autoscale = true`. To avoid the conflict between the actual `size` of a nodepool and the `size` defined in the terraform configuration files, you can add the `ignore_initial_pool_size = true` attribute to the nodepool definition in the `worker_pools` variable. This parameter will allow terraform to ignore the [drift](https://developer.hashicorp.com/terraform/tutorials/state/resource-drift) of the size parameter for the specific nodepool.

This setting is strongly recommended for nodepools configured with `autoscale = true`.

Example:

```
worker_pools = {
  np-autoscaled = {
    description              = "Node pool managed by cluster autoscaler",
    size                     = 2,
    min_size                 = 1,
    max_size                 = 3,
    autoscale                = true,
    ignore_initial_pool_size = true # allows nodepool size drift
  },
  np-autoscaler = {
    description      = "Node pool with cluster autoscaler scheduling allowed",
    size             = 1,
    allow_autoscaler = true,
  },
}

```


For existing deployments is necessary to use the [terraform state mv](https://developer.hashicorp.com/terraform/cli/commands/state/mv) command.

Example for `nodepool` resource:
```

$ terraform plan
...
Terraform will perform the following actions:
  
  # module.oke.module.workers[0].oci_containerengine_node_pool.tfscaled_workers["np-autoscaled"] will be destroyed
...

  # module.oke.module.workers[0].oci_containerengine_node_pool.autoscaled_workers["np-autoscaled"] will be created


$ terraform state mv module.oke.module.workers[0].oci_containerengine_node_pool.tfscaled_workers[\"np-autoscaled\"]  module.oke.module.workers[0].oci_containerengine_node_pool.autoscaled_workers[\"np-autoscaled\"]

Successfully moved 1 object(s).

$ terraform plan
...
No changes. Your infrastructure matches the configuration.

```

Example for `instance_pool` resource:

```
$ terraform state mv module.oke.module.workers[0].oci_core_instance_pool.tfscaled_workers[\"np-autoscaled\"] module.oke.module.workers[0].oci_core_instance_pool.autoscaled_workers[\"np-autoscaled\"]

Successfully moved 1 object(s).

```

### Notes

Don't set `allow_autoscaler` and `autoscale` to `true` on the same pool. This will cause the cluster autoscaler pod to be unschedulable as the `oke.oraclecloud.com/cluster_autoscaler: managed` node label will override the `oke.oraclecloud.com/cluster_autoscaler: allowed` node label specified by the cluster autoscaler `nodeSelector` pod attribute.

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-cluster-autoscaler.auto.tfvars:4:}}
```

```javascript
{{#include ../../../examples/workers/vars-workers-autoscaling.auto.tfvars:4:}}
```

## References
* [Cluster Autoscaler Helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)
* [Autoscaling Kubernetes Node Pools and Pods](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengautoscalingclusters.htm)
* [OCI Provider for Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/oci#cluster-autoscaler-for-oracle-cloud-infrastructure-oci)
* [Cluster Autoscaler FAQ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md)