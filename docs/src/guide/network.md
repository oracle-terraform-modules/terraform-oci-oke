# Network

Optional creation of VCN subnets, Network Security Groups, NSG Rules, and more.

## Examples

### Create Minimal Network Resources

**TODO**: ../../../examples/network/vars-network-only-minimal.auto.tfvars

```javascript
{{#include ../../../examples/network/vars-network.auto.tfvars:4:15:}}
```

### Create Common Network Resources

```javascript
{{#include ../../../examples/network/vars-network.auto.tfvars:4:}}
```

## References

* [Terraform VCN Module](https://github.com/oracle-terraform-modules/terraform-oci-vcn)
* [VCNs and Subnets](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/VCNs.htm)
* [OCI Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [Internet Gateways](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIGs.htm)
* [NAT Gateways](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm)
