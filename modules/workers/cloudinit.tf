# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "cloudinit_config" "workers" {
  for_each      = local.enabled_worker_pools
  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = each.value.os == "Oracle Linux" ? "text/x-shellscript" : "text/x-shellscript-per-boot"
    content = coalesce(each.value.cloudinit, templatefile("${path.module}/cloudinit/worker.template.sh", {
      cluster_ca_cert = var.cluster_ca_cert
      apiserver_host  = var.apiserver_private_host
      timezone        = var.timezone
    }))
  }
}
