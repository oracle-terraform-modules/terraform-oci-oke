locals {
  worker_script_template = templatefile("${path.module}/cloudinit/worker.template.sh",
    {
      worker_timezone = var.node_pool_timezone
    }
  )

}

# cloud-init for workers
data "cloudinit_config" "worker" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = "text/x-shellscript"
    content      = local.worker_script_template
  }

}

