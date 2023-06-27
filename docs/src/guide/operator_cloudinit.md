# Operator: Cloud-Init

Custom actions may be configured on instance startup in an number of ways depending on the use-case and preferences.

See also:
* [`template_cloudinit_config`](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html)
* [User data formats](https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive)
* [Module reference](https://cloudinit.readthedocs.io/en/latest/reference/modules.html)

Cloud init configuration applied to the operator host:
```javascript
{{#include ../../../examples/operator/vars-operator-cloudinit.auto.tfvars:4:}}
```
