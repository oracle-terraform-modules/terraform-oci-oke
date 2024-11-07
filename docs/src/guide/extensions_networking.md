# Extensions: Networking

****
**WARNING:** The following options are provided as a reference for evaluation only, and may install software to the cluster that is not supported by or sourced from Oracle. These features should be enabled with caution as their operation is not guaranteed!
****

## Multus CNI

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-multus.auto.tfvars:4:}}
```

### References
* [k8snetworkplumbingwg/multus-cni](https://github.com/k8snetworkplumbingwg/multus-cni)

****

## Cilium CNI

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-cilium.auto.tfvars:4:}}
```

Cillium is a eBPF based CNI for Kubernetes that can be configured on OKE clusters.

The OKE cluster should be initially configured to run **flannel**. 

On **enhanced** clusters we can use the cluster-addons module to remove flannel extension and kube-proxy (Optional) at cluster creation. 


```
cluster_addons_to_remove = {
  Flannel = {
    remove_k8s_resources = true
  },
  KubeProxy = {
    remove_k8s_resources = true
  }
}
```

If you want to use cilium as [kube-proxy replacement](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/), you can use the following helm_values:

```
cilium_helm_values      = {
  kubeProxyReplacement = true
}
```

For the basic clusters you can add the following label to the worker nodes to prevent flannel pods from being scheduled:

```
oci.oraclecloud.com/custom-k8s-networking=true
```

If you want to override and of the default values(listed below) you can use the `cilium_helm_values` variable:

```
"annotateK8sNode": true
"cluster":
  "id": 1
  "name": "oke-${var.state_id}"
"clustermesh":
  "apiserver":
    "kvstoremesh":
      "enabled": false
  "useAPIServer": false
"cni":
  "exclusive": true
  "install": true
"hubble":
  "metrics":
    "dashboards":
      "enabled": false
  "relay":
    "enabled": true
  "ui":
    "enabled": true
"installNoConntrackIptablesRules": false
"ipam":
  "mode": "kubernetes"
"k8s":
  "requireIPv4PodCIDR": true
"k8sServiceHost": "${var.cluster_private_endpoint}"
"k8sServicePort": "6443"
"kubeProxyReplacement": false
"operator":
  "prometheus":
    "enabled": false
"pmtuDiscovery":
  "enabled": true
"rollOutCiliumPods": true
"tunnelProtocol": "vxlan"
```


**Notes:**
1. Tested with OKE version `v1.29.1` and the worker nodes running: `Oracle-Linux-8.9-2024.05.29-0-OKE-1.29.1-707`.

2. In case the `hubble-relay` and `hubble-ui` pods fail to start, run the following commands:

```
kubectl delete pod --namespace kube-system -l k8s-app=kube-dns
kubectl delete pod --namespace kube-system -l k8s-app=hubble-relay
kubectl delete pod --namespace kube-system -l k8s-app=hubble-ui
kubectl delete pod --namespace kube-system -l k8s-app=kube-dns-autoscaler
```

### References
* [cilium.io](https://cilium.io)

****

## Whereabouts IPAM plugin

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-whereabouts.auto.tfvars:4:}}
```

### References
* [k8snetworkplumbingwg/whereabouts](https://github.com/k8snetworkplumbingwg/whereabouts)

****

## SR-IOV Device plugin

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-sriov-device.auto.tfvars:4:}}
```

### References
* [k8snetworkplumbingwg/sriov-network-device-plugin](https://github.com/k8snetworkplumbingwg/sriov-network-device-plugin)

****

## SR-IOV CNI plugin

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-sriov-cni.auto.tfvars:4:}}
```

### References
* [openshift/sriov-cni](https://github.com/openshift/sriov-cni)

****

## RDMA CNI plugin

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-rdma-cni.auto.tfvars:4:}}
```

### References
* [k8snetworkplumbingwg/rdma-cni](https://github.com/k8snetworkplumbingwg/rdma-cni)

****
