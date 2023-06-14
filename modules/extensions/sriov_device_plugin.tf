# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  sriov_device_plugin_url = "https://raw.githubusercontent.com/k8snetworkplumbingwg/sriov-network-device-plugin"
  sriov_device_plugin_daemonset_url = coalesce(
    var.sriov_device_plugin_daemonset_url,
    "${local.sriov_device_plugin_url}/${var.sriov_device_plugin_version}/deployments/sriovdp-daemonset.yaml"
  )
  sriov_device_plugin_manifest_path        = join("/", [local.yaml_manifest_path, "sriov_device_plugin-manifest.yaml"])
  sriov_device_plugin_manifest_status_code = one(data.http.sriov_device_plugin[*].status_code)
  sriov_device_plugin_manifest_content     = sensitive(one(data.http.sriov_device_plugin[*].response_body))
}

data "http" "sriov_device_plugin" {
  count = var.sriov_device_plugin_install ? 1 : 0
  url   = local.sriov_device_plugin_daemonset_url
}

resource "null_resource" "sriov_device_plugin" {
  count = var.sriov_device_plugin_install ? 1 : 0

  triggers = {
    sriov_device_plugin_daemonset_url = local.sriov_device_plugin_daemonset_url
    sriov_device_plugin_daemonset_md5 = md5(local.sriov_device_plugin_manifest_content)
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
    content     = local.sriov_device_plugin_manifest_content
    destination = local.sriov_device_plugin_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format(local.kubectl_apply_file, local.sriov_device_plugin_manifest_path),
    ]
  }

  lifecycle {
    precondition {
      condition     = local.sriov_device_plugin_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving SR-IOV Daemonset manifest
      URL: ${local.sriov_device_plugin_daemonset_url}
      Status code: ${local.sriov_device_plugin_manifest_status_code}
      Response: ${local.sriov_device_plugin_manifest_content}
      EOT
    }
  }
}
