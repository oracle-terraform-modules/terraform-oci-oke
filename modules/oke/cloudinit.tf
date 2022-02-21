locals {
  worker_script_template = templatefile("${path.module}/cloudinit/worker.template.sh",
    {
      worker_timezone = var.node_pool_timezone
    }
  )
  # example for adding more script 
  # second_script_template = templatefile("${path.module}/cloudinit/second.template.sh",{})
}

# cloud-init for workers
data "cloudinit_config" "worker" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = "text/x-shellscript"
    content      = local.worker_script_template
  }
  
  # example for adding more script
  # part {
  #   filename     = "second.sh"
  #   content_type = "text/x-shellscript"
  #   content      = local.second_script_template
  # }
}

