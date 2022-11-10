# Copyright 2022 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  script_args = {
    apiserver_host  = var.apiserver_host
    cluster_ca_cert = local.cluster_ca_cert
    cluster_dns     = var.cluster_dns
    sriov_num_vfs   = var.sriov_num_vfs
    timezone        = var.timezone
  }
}

data "cloudinit_config" "worker_np" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = "text/x-shellscript-per-boot"
    content      = templatefile("${path.module}/cloudinit/worker.np.sh", local.script_args)
  }
}

data "cloudinit_config" "worker_ip" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = "text/x-shellscript-per-boot"
    content      = templatefile("${path.module}/cloudinit/worker.ip.sh", local.script_args)
  }
}