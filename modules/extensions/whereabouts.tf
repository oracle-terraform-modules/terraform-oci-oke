# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  whereabouts_url                     = "https://raw.githubusercontent.com/k8snetworkplumbingwg/whereabouts/${var.whereabouts_version}/doc/crds"
  whereabouts_ippools_url             = "${local.whereabouts_url}/whereabouts.cni.cncf.io_ippools.yaml"
  whereabouts_overlap_res_url         = "${local.whereabouts_url}/whereabouts.cni.cncf.io_overlappingrangeipreservations.yaml"
  whereabouts_daemonset_url           = coalesce(var.whereabouts_daemonset_url, "${local.whereabouts_url}/daemonset-install.yaml")
  whereabouts_ippools_path            = join("/", [local.yaml_manifest_path, "whereabouts.ippools.crd.yaml"])
  whereabouts_ippools_status_code     = one(data.http.whereabouts_ippools[*].status_code)
  whereabouts_ippools_content         = sensitive(one(data.http.whereabouts_ippools[*].response_body))
  whereabouts_overlap_res_path        = join("/", [local.yaml_manifest_path, "whereabouts.overlap_res.crd.yaml"])
  whereabouts_overlap_res_status_code = one(data.http.whereabouts_overlap_res[*].status_code)
  whereabouts_overlap_res_content     = sensitive(one(data.http.whereabouts_overlap_res[*].response_body))
  whereabouts_manifest_path           = join("/", [local.yaml_manifest_path, "whereabouts.manifest.yaml"])
  whereabouts_manifest_status_code    = one(data.http.whereabouts_daemonset[*].status_code)
  whereabouts_manifest_content        = sensitive(one(data.http.whereabouts_daemonset[*].response_body))
}

data "http" "whereabouts_ippools" {
  count = var.whereabouts_install ? 1 : 0
  url   = local.whereabouts_ippools_url
}

data "http" "whereabouts_overlap_res" {
  count = var.whereabouts_install ? 1 : 0
  url   = local.whereabouts_overlap_res_url
}

data "http" "whereabouts_daemonset" {
  count = var.whereabouts_install ? 1 : 0
  url   = local.whereabouts_daemonset_url
}

resource "null_resource" "whereabouts" {
  count = var.whereabouts_install ? 1 : 0

  triggers = {
    whereabouts_ippools_url     = local.whereabouts_ippools_url
    whereabouts_overlap_res_url = local.whereabouts_overlap_res_url
    whereabouts_daemonset_url   = local.whereabouts_daemonset_url
    whereabouts_ippools_md5     = md5(local.whereabouts_ippools_content)
    whereabouts_overlap_res_md5 = md5(local.whereabouts_overlap_res_content)
    whereabouts_daemonset_md5   = md5(local.whereabouts_manifest_content)
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
    content     = local.whereabouts_ippools_content
    destination = local.whereabouts_ippools_path
  }

  provisioner "file" {
    content     = local.whereabouts_overlap_res_content
    destination = local.whereabouts_overlap_res_path
  }

  provisioner "file" {
    content     = local.whereabouts_manifest_content
    destination = local.whereabouts_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format("${local.kubectl} apply -f %s -f %s -f %s",
        local.whereabouts_ippools_path,
        local.whereabouts_overlap_res_path,
        local.whereabouts_manifest_path
      )
    ]
  }

  lifecycle {
    precondition {
      condition     = local.whereabouts_ippools_status_code == 200
      error_message = <<-EOT
      Error retrieving Whereabouts CRD
      URL: ${local.whereabouts_ippools_url}
      Status code: ${local.whereabouts_ippools_status_code}
      Response: ${local.whereabouts_ippools_content}
      EOT
    }
    precondition {
      condition     = local.whereabouts_overlap_res_status_code == 200
      error_message = <<-EOT
      Error retrieving Whereabouts CRD
      URL: ${local.whereabouts_overlap_res_url}
      Status code: ${local.whereabouts_overlap_res_status_code}
      Response: ${local.whereabouts_overlap_res_content}
      EOT
    }
    precondition {
      condition     = local.whereabouts_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving Whereabouts manifest
      URL: ${local.whereabouts_daemonset_url}
      Status code: ${local.whereabouts_manifest_status_code}
      Response: ${local.whereabouts_manifest_content}
      EOT
    }
  }
}
