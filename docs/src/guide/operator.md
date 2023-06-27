# Operator

The operator instance provides an optional environment within the VCN from which the OKE cluster can be managed.

The operator host parameters concern:
1. whether you want to enable the operator
1. from where you can access the operator
1. the different parameters about the operator host e.g. shape, image id etc.

### Example usage
```javascript
{{#include ../../../examples/operator/vars-operator.auto.tfvars:4:}}
```
