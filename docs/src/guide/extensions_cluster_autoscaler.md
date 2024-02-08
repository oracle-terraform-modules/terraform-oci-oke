# Extensions: Cluster Autoscaler

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

### Notes

Don't set `allow_autoscaler` and `autoscale` to `true` on the same pool. This will cause the cluster autoscaler pod to be unschedulable as the `oke.oraclecloud.com/cluster_autoscaler: managed` node label will override the `oke.oraclecloud.com/cluster_autoscaler: allowed` node label specified by the cluster autoscaler `nodeSelector` pod attribute.

If you aren't using the operator you can deploy the helm chart using your the same device that is running Terraform.
Just set `var.cluster_autoscaler_remote_exec` to `false`, and make sure your kubectl config is set via `KUBE_CONFIG_PATH`
environment variable.

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
