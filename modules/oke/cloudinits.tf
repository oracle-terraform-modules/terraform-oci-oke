locals {
  worker_template = "${path.module}/cloudinit/worker.template.yaml"

  # worker_template = "${path.module}/cloudinit/worker.template.sh"
}

# cloud-init for workers
data "cloudinit_config" "worker" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "worker.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      local.worker_template, {
        worker_timezone = "Australia/Sydney"
      }
    )
  }
}

