# Workers

The `worker_pools` input defines worker node configuration for the cluster.

Many of the global configuration values below may be overridden on each pool definition or omitted for defaults, with the `worker_` or `worker_pool_` variable prefix removed, e.g. `worker_image_id` overridden with `image_id`.

For example:
```javascript
{{#include ../../../examples/workers/vars-workers-basic.auto.tfvars:4:}}
```
