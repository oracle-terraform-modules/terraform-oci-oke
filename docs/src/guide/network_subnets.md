# Subnets

Subnets are created for core components managed within the module, namely:
* Bastion
* Operator
* Control plane (`cp`)
* Workers
* Pods
* Internal load balancers (`int_lb`)
* Public load balancers (`pub_lb`)

## Create new subnets (automatic)

```javascript
{{#include ../../../examples/network/vars-network-subnets-create.auto.tfvars:4:}}
```

## Create new subnets (forced)

```javascript
{{#include ../../../examples/network/vars-network-subnets-create-force.auto.tfvars:4:}}
```

## Create new subnets (CIDR notation)

```javascript
{{#include ../../../examples/network/vars-network-subnets-create-cidr.auto.tfvars:4:}}
```

## Create new subnets with IPv4 and IPv6 (CIDR notation)

```javascript
{{#include ../../../examples/network/vars-network-subnets-create-cidr-ipv4-and-ipv6.tfvars:4:}}
```

## Use existing subnets

```javascript
{{#include ../../../examples/network/vars-network-subnets-existing.auto.tfvars:4:}}
```

## References

* [OCI Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [VCNs and Subnets](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/VCNs.htm)
* Terraform [cidrsubnets](https://developer.hashicorp.com/terraform/language/functions/cidrsubnets) function
