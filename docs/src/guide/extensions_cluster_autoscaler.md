# Extensions: Cluster Autoscaler

Deployed using the [cluster-autoscaler Helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler) with configuration from `worker_pools`.

The following parameters may be added on each pool definition to enable management or scheduling of the cluster autoscaler:
* `allow_autoscaler`: Enable scheduling of the cluster autoscaler deployment on a pool by adding a node label matching the deployment's nodeSelector, and an OCI tag for use with [IAM tag-based policies](https://docs.oracle.com/en-us/iaas/Content/Tagging/Tasks/managingaccesswithtags.htm) granting access to the instances.
* `autoscale`: Enable cluster autoscaler management of the pool by including a `--nodes` argument for it.
* `min_size`: Define the minimum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.
* `max_size`: Define the maximum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-cluster-autoscaler.auto.tfvars:4:}}
```

## References
* [Cluster Autoscaler Helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)
* [Autoscaling Kubernetes Node Pools and Pods](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengautoscalingclusters.htm)
