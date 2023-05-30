# Cluster extensions

****
**WARNING:** The following options are provided as a reference for evaluation only, and may install software to the cluster that is not supported by or sourced from Oracle. These features should be enabled with caution as their operation is not guaranteed!
****

## [Gatekeeper](https://open-policy-agent.github.io/gatekeeper)

See [Extensions/Gatekeeper](link:networking.adoc#net_multus).

## Multus

See [Networking/Multus](link:networking.adoc#net_multus).

## Calico

See [Networking/Calico](link:networking.adoc#net_calico).

**NOTE:** Pending validation in 5.x

## Cilium

See [Networking/Cilium](link:networking.adoc#net_cilium).

**NOTE:** Pending validation in 5.x

## [Cluster autoscaler](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler)

Deployed using the [cluster-autoscaler Helm chart](https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler) with configuration from `worker_pools`.

Refer to [Autoscaling Kubernetes Node Pools and Pods](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengautoscalingclusters.htm) for additional information.

The following parameters may be added on each pool definition to enable management or scheduling of the cluster autoscaler:
* `allow_autoscaler`: Enable scheduling of the cluster autoscaler deployment on a pool by adding a node label matching the deployment's nodeSelector, and an OCI tag for use with [IAM tag-based policies](https://docs.oracle.com/en-us/iaas/Content/Tagging/Tasks/managingaccesswithtags.htm) granting access to the instances.
* `autoscale`: Enable cluster autoscaler management of the pool by including a `--nodes` argument for it.
* `minSize`: Define the minimum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.
* `maxSize`: Define the minimum scale of a pool managed by the cluster autoscaler. Defaults to `size` when not provided.
