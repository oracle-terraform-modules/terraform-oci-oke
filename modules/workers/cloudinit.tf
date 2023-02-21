# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive
  default_cloud_init_content_type = "text/x-shellscript"

  # https://canonical-cloud-init.readthedocs-hosted.com/en/latest/reference/merging.html
  default_cloud_init_merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html
data "cloudinit_config" "workers" {
  for_each      = local.enabled_worker_pools
  gzip          = true
  base64_encode = true

  # Include global and pool-specific custom cloud init MIME parts
  dynamic "part" {
    for_each = each.value.cloud_init
    iterator = part
    content {
      content      = lookup(part.value, "content", "")
      content_type = lookup(part.value, "content_type", local.default_cloud_init_content_type)
      filename     = lookup(part.value, "filename", null)
      merge_type   = lookup(part.value, "merge_type", local.default_cloud_init_merge_type)
    }
  }

  # Set timezone
  part {
    content_type = "text/cloud-config"
    # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#timezone
    content  = jsonencode({ timezone = var.timezone })
    filename = "10-timezone.yml"
  }

  # Expand root filesystem to fill available space on volume
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#growpart
      growpart = {
        mode                     = "auto"
        devices                  = ["/"]
        ignore_growroot_disabled = false
      }

      # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#resizefs
      resize_rootfs = true

      # Resize logical LVM root volume when utility is present
      bootcmd = ["if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y; fi"]
    })
    filename   = "10-growpart.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # Write extra OKE configuration to filesystem
  part {
    content_type = "text/cloud-config"
    content = jsonencode({
      write_files = [
        {
          content = var.apiserver_private_host
          path    = "/etc/oke/oke-apiserver"
        },
        {
          content  = var.cluster_ca_cert
          encoding = "base64"
          path     = "/etc/kubernetes/ca.crt"
        },
      ]
    })
    filename   = "50-oke-config.yml"
    merge_type = local.default_cloud_init_merge_type
  }

  # OKE startup initialization
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/cloudinit-oke.sh")
    filename     = "50-oke.sh"
    merge_type   = local.default_cloud_init_merge_type
  }

  lifecycle {
    precondition {
      condition = alltrue([for c in var.cloud_init :
        trimspace(lookup(c, "content", "")) != ""
      ])
      error_message = <<-EOT
      Each global cloud_init map entry must include a non-empty 'content' field.
      See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html.
      var.cloud_init (${each.key}): ${try(jsonencode(var.cloud_init), "invalid")}
      EOT
    }

    precondition {
      condition = alltrue([for c in var.cloud_init :
        length(regexall("^text/[a-z-]*$", trimspace(lookup(c, "content_type", local.default_cloud_init_content_type)))) > 0
      ])
      error_message = <<-EOT
      Each global cloud_init map entry must include a 'content_type' field prefixed with 'text/'.
      See https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive.
      var.cloud_init (${each.key}): ${try(jsonencode(var.cloud_init), "invalid")}
      EOT
    }

    precondition {
      condition = alltrue([for c in each.value.cloud_init :
        trimspace(lookup(c, "content", "")) != ""
      ])
      error_message = <<-EOT
      Each pool-specific cloud_init map entry must include a non-empty 'content' field.
      See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html.
      ${each.key}["cloud_init"]: ${try(jsonencode(each.value.cloud_init), "invalid")}
      EOT
    }

    precondition {
      condition = alltrue([for c in each.value.cloud_init :
        length(regexall("^text/[a-z-]+$", trimspace(lookup(c, "content_type", local.default_cloud_init_content_type)))) > 0
      ])
      error_message = <<-EOT
      Each pool-specific cloud_init map entry must include a 'content_type' field prefixed with 'text/'.
      See https://cloudinit.readthedocs.io/en/latest/explanation/format.html#mime-multi-part-archive.
      ${each.key}["cloud_init"]: ${try(jsonencode(each.value.cloud_init), "invalid")}
      EOT
    }
  }
}
