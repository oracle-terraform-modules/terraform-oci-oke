# Cluster

See also:
* [Creating a Kubernetes Cluster](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke.htm)

The OKE parameters concern mainly the following:
* whether you want your OKE control plane to be public or private
* whether you want to deploy public or private worker nodes
* whether you want to allow NodePort or ssh access to the worker nodes
* Kubernetes options such as dashboard, networking
* number of node pools and their respective size of the cluster
* services and pods cidr blocks
* whether to use encryption

```admonish notice
 If you need to change the default services and pods' CIDRs, note the following:
* The CIDR block you specify for the VCN *must not* overlap with the CIDR block you specify for the Kubernetes services.
* The CIDR blocks you specify for pods running in the cluster *must not* overlap with CIDR blocks you specify for worker node and load balancer subnets.
```

## Example usage

Basic cluster with defaults:
```javascript
{{#include ../../../examples/cluster/vars-cluster-basic.auto.tfvars:4:}}
```

Enhanced cluster with extra configuration:
```javascript
{{#include ../../../examples/cluster/vars-cluster-enhanced.auto.tfvars:4:}}
```
