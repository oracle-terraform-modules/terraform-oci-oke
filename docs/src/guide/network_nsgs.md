# Network Security Groups

Network Security Groups (NSGs) are used to permit network access between resources creation by the module, namely:
* Bastion
* Operator
* Control plane (`cp`)
* Workers
* Pods
* Internal load balancers (`int_lb`)
* Public load balancers (`pub_lb`)

## Create new NSGs
```javascript
{{#include ../../../examples/network/vars-network-nsgs-create.auto.tfvars:4:}}
```

## Use existing NSGs
```javascript
{{#include ../../../examples/network/vars-network-nsgs-existing.auto.tfvars:4:}}
```

## References

* [OCI Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [Security Rule Configuration in Network Security Groups](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#securitylistconfig)
