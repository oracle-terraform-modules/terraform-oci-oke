# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  rdma_cni_plugin_url = "https://raw.githubusercontent.com/k8snetworkplumbingwg/rdma-cni"
  rdma_cni_plugin_daemonset_url = coalesce(
    var.rdma_cni_plugin_daemonset_url,
    "${local.rdma_cni_plugin_url}/${var.rdma_cni_plugin_version}/deployment/rdma-cni-daemonset.yaml"
  )
  rdma_cni_plugin_manifest_path        = join("/", [local.yaml_manifest_path, "rdma-cni-daemonset.yaml"])
  rdma_cni_plugin_manifest_status_code = one(data.http.rdma_cni_plugin[*].status_code)
  rdma_cni_plugin_manifest_content     = one(data.http.rdma_cni_plugin[*].response_body)
}

data "http" "rdma_cni_plugin" {
  count = var.rdma_cni_plugin_install ? 1 : 0
  url   = local.rdma_cni_plugin_daemonset_url
}

resource "null_resource" "rdma_cni_plugin" {
  count = var.rdma_cni_plugin_install ? 1 : 0

  triggers = {
    rdma_cni_plugin_daemonset_url = local.rdma_cni_plugin_daemonset_url
    rdma_cni_plugin_daemonset_md5 = md5(local.rdma_cni_plugin_manifest_content)
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
    content     = local.rdma_cni_plugin_manifest_content
    destination = local.rdma_cni_plugin_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format(local.kubectl_apply_file, local.rdma_cni_plugin_manifest_path),
    ]
  }

  lifecycle {
    precondition {
      condition     = local.rdma_cni_plugin_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving RDMA CNI Daemonset manifest
      URL: ${local.rdma_cni_plugin_daemonset_url}
      Status code: ${local.rdma_cni_plugin_manifest_status_code}
      Response: ${local.rdma_cni_plugin_manifest_content}
      EOT
    }
  }
}
