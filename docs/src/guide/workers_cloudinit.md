# Workers: Cloud-Init

Custom actions may be configured on instance startup in an number of ways depending on the use-case and preferences.

See also:
* [`template_cloudinit_config`](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html)
* [User data formats](https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive)
* [Module reference](https://cloudinit.readthedocs.io/en/latest/reference/modules.html)

## Global

Cloud init configuration applied to all workers:
```javascript
{{#include ../../../examples/workers/vars-workers-cloudinit-global.auto.tfvars:4:}}
```

## Pool-specific

Cloud init configuration applied to a specific worker pool:
```javascript
{{#include ../../../examples/workers/vars-workers-cloudinit-pool.auto.tfvars:4:}}
```

## Default Cloud-Init Disabled

When providing a custom script that calls OKE initialization:
```properties
worker_disable_default_cloud_init = true
```
