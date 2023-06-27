# Bastion

The bastion instance provides a public SSH entrypoint into the VCN from which resources in private subnets may be accessed - recommended to limit public IP usage and exposure.

The bastion host parameters concern:
0. whether you want to enable the bastion
0. from where you can access the bastion
0. the different parameters about the bastion host e.g. shape, image id etc.

## Image

The OS image for the created bastion instance.

**Recommended:** [Oracle Autonomous Linux 8.x](https://docs.oracle.com/en-us/iaas/images/autonomous-linux-8x)

## Example usage
```javascript
{{#include ../../../examples/bastion/vars-bastion.auto.tfvars:4:}}
```
