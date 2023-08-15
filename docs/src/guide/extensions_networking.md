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
