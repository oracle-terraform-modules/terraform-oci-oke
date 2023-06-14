# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  sriov_cni_plugin_url = "https://raw.githubusercontent.com/openshift/sriov-cni"
  sriov_cni_plugin_daemonset_url = coalesce(
    var.sriov_cni_plugin_daemonset_url,
    "${local.sriov_cni_plugin_url}/${var.sriov_cni_plugin_version}/images/k8s-v1.16/sriov-cni-daemonset.yaml"
  )
  sriov_cni_plugin_manifest_path        = join("/", [local.yaml_manifest_path, "sriov_cni_plugin-manifest.yaml"])
  sriov_cni_plugin_manifest_status_code = one(data.http.sriov_cni_plugin[*].status_code)
  sriov_cni_plugin_manifest_content     = sensitive(one(data.http.sriov_cni_plugin[*].response_body))
}

data "http" "sriov_cni_plugin" {
  count = var.sriov_cni_plugin_install ? 1 : 0
  url   = local.sriov_cni_plugin_daemonset_url
}

resource "null_resource" "sriov_cni_plugin" {
  count = var.sriov_cni_plugin_install ? 1 : 0

  triggers = {
    sriov_cni_plugin_daemonset_url = local.sriov_cni_plugin_daemonset_url
    sriov_cni_plugin_daemonset_md5 = md5(local.sriov_cni_plugin_manifest_content)
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
    content     = local.sriov_cni_plugin_manifest_content
    destination = local.sriov_cni_plugin_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format(local.kubectl_apply_file, local.sriov_cni_plugin_manifest_path),
    ]
  }

  lifecycle {
    precondition {
      condition     = local.sriov_cni_plugin_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving SR-IOV CNI Daemonset manifest
      URL: ${local.sriov_cni_plugin_daemonset_url}
      Status code: ${local.sriov_cni_plugin_manifest_status_code}
      Response: ${local.sriov_cni_plugin_manifest_content}
      EOT
    }
  }
}
