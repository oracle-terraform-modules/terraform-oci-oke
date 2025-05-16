# Cluster Add-ons

With this module you can manage both essential and optional add-ons on **enhanced** OKE clusters. 

This module provides the option to remove [Essential addons](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengintroducingclusteraddons.htm#contengintroducingclusteraddons__section-essential-addons) and to manage, both essential & [optional addons](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengintroducingclusteraddons.htm#contengintroducingclusteraddons__section-optional-addons).

Cluster add-on removal (using the `cluster_addons_to_remove` variable) requires the creation of the operator host.

To list the available cluster add-ons for a specific Kubernetes version you can run the following oci-cli command:

```
oci ce addon-option list --kubernetes-version <k8s-version>
```

**Note**: For the cluster autoscaler you should choose **only one** of the options:
- the stand-alone cluster-autoscaler deployment, using the [extension module](./extensions_cluster_autoscaler.md)
- the cluster-autoscaler add-on

When customizing the configuration of an existing addon, use the flag `override_existing=true`. Default value is false if not specified.

## Example usage
```javascript
{{#include ../../../examples/cluster-addons/vars-cluster-addons.auto.tfvars:4:}}
```

## Reference
* [OKE Cluster Add-ons Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons.htm)
