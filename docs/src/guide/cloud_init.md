# cloud-init

## Configuring cloud-init
Custom actions may be configured on instance startup in an number of ways depending on the use-case and preferences.

See also:
* [`template_cloudinit_config`](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html)
* [User data formats](https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive)
* [Module reference](https://cloudinit.readthedocs.io/en/latest/reference/modules.html)

### Operator

Cloud init configuration applied to the operator host:
```
operator_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Operator cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config",
  },
  {
    content      = "/path/to/file"
    content_type = "text/cloud-boothook",
  },
  {
    content      = "<Base64-encoded content>"
    content_type = "text/x-shellscript",
  },
]
```

### Workers (global)

Cloud init configuration applied to all workers:
```
worker_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Global cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config",
  },
  {
    content      = "/path/to/file"
    content_type = "text/cloud-boothook",
  },
  {
    content      = "<Base64-encoded content>"
    content_type = "text/x-shellscript",
  },
]
```

### Workers (pool-specific)

Cloud init configuration applied to a specific worker pool:
```
worker_pools = {
  pool_default = {}
  pool_custom = {
    cloud_init = [
      {
        content      = <<-EOT
        runcmd:
        - echo "Pool-specific cloud_init using cloud-config"
        EOT
        content_type = "text/cloud-config",
      },
      {
        content      = "/path/to/file"
        content_type = "text/cloud-boothook",
      },
      {
        content      = "<Base64-encoded content>"
        content_type = "text/x-shellscript",
      },
    ]
  }
}
```
