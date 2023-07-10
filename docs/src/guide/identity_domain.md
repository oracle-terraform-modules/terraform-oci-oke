# IAM with Identity Domains

Creation of Identity [Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/dynamicgroups/managingdynamicgroups.htm), [Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingpolicies.htm), and Tags.


## Context

While you might not have the necessary policy permissions to provision OKE clusters directly at Tenancy level (ROOT compartment) and you have full control only under a sub-compartment, the following parameters will allow you to reference an existing and custom `identity domain` at this sub-compartment level. The `Dynamic Groups` will be then created in this Identity Domain while the policies will be created at the sub-compartment level and their statements using the `dynamic group` in your `identity domain`

Moreover, You can use this Identity Domain, to create service account users for your Kubernetes/OKE controllers or operators.

## Usage

```javascript
{{#include ../../../examples/iam/vars-subcompartment-iam-identitydomain.auto.tfvars:4:}}
```
