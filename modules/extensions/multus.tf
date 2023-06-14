# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  multus_url = "https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni"
  multus_daemonset_url = coalesce(
    var.multus_daemonset_url,
    "${local.multus_url}/v${var.multus_version}/deployments/multus-daemonset.yml"
  )
  multus_manifest_path        = join("/", [local.yaml_manifest_path, "multus.manifest.yaml"])
  multus_manifest_status_code = one(data.http.multus[*].status_code)
  multus_manifest_content     = sensitive(one(data.http.multus[*].response_body))
}

data "http" "multus" {
  count = var.multus_install ? 1 : 0
  url   = local.multus_daemonset_url
}

resource "null_resource" "multus" {
  count = var.multus_install ? 1 : 0

  triggers = {
    multus_daemonset_url = local.multus_daemonset_url
    multus_daemonset_md5 = md5(local.multus_manifest_content)
  }

  connection {
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
    host                = var.operator_host
    user                = var.operator_user
    private_key         = var.ssh_private_key
    timeout             = "40m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.yaml_manifest_path}"]
  }

  provisioner "file" {
    content     = local.multus_manifest_content
    destination = local.multus_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format(local.kubectl_apply_file, local.multus_manifest_path),
    ]
  }

  lifecycle {
    precondition {
      condition     = local.multus_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving Multus Daemonset manifest
      Status code: ${local.multus_manifest_status_code}
      Response: ${local.multus_manifest_content}
      EOT
    }
  }
}
