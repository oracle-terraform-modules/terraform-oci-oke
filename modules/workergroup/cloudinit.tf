# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# TODO Collapse w/ variable content_type for cloud-init versions
data "cloudinit_config" "worker_once" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.template.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/cloudinit/worker.template.sh", {
      cluster_ca_cert = local.cluster_ca_cert
      apiserver_host  = var.apiserver_private_host
    })
  }
}

data "cloudinit_config" "worker_per_boot" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.template.sh"
    content_type = "text/x-shellscript-per-boot"
    content = templatefile("${path.module}/cloudinit/worker.template.sh", {
      cluster_ca_cert = local.cluster_ca_cert
      apiserver_host  = var.apiserver_private_host
    })
  }
}
