# Cluster Add-ons

With this module to manage both essential and optional add-ons on enhanced OKE clusters. 

This module provides the option to remove [Essential addons](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengintroducingclusteraddons.htm#contengintroducingclusteraddons__section-essential-addons) and to manage, both essential & [optional addons](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengintroducingclusteraddons.htm#contengintroducingclusteraddons__section-optional-addons).

Cluster add-on removal (using the `cluster_addons_to_remove` variable) requires the creation of the operator host.

**Note**: For the cluster autoscaler you should choose **only one** of the options:
- the stand-alone cluster-autoscaler deployment, using the [extension module](./extensions_cluster_autoscaler.md)
- the cluster-autoscaler add-on

## Example usage
```javascript
{{#include ../../../examples/cluster-addons/vars-cluster-addons.auto.tfvars:4:}}
```

## Reference
* [OKE Cluster Add-ons Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons.htm)
