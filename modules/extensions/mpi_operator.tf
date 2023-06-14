# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  mpi_operator_url = "https://raw.githubusercontent.com/kubeflow/mpi-operator/v${var.mpi_operator_version}/deploy/v2beta1"
  mpi_operator_deployment_url = coalesce(
    var.mpi_operator_deployment_url,
    "${local.mpi_operator_url}/mpi-operator.yaml"
  )
  mpi_operator_manifest_path        = join("/", [local.yaml_manifest_path, "mpi-operator.manifest.yaml"])
  mpi_operator_manifest_status_code = one(data.http.mpi_operator[*].status_code)
  mpi_operator_manifest_content     = sensitive(one(data.http.mpi_operator[*].response_body))
}

data "http" "mpi_operator" {
  count = var.mpi_operator_install ? 1 : 0
  url   = local.mpi_operator_deployment_url
}

resource "null_resource" "mpi_operator" {
  count = var.mpi_operator_install ? 1 : 0

  triggers = {
    mpi_operator_deployment_url = local.mpi_operator_deployment_url
    mpi_operator_deployment_md5 = md5(local.mpi_operator_manifest_content)
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
    content     = local.mpi_operator_manifest_content
    destination = local.mpi_operator_manifest_path
  }

  provisioner "remote-exec" {
    inline = [
      format(local.kubectl_apply_file, local.mpi_operator_manifest_path),
    ]
  }

  lifecycle {
    precondition {
      condition     = local.mpi_operator_manifest_status_code == 200
      error_message = <<-EOT
      Error retrieving MPI Operator manifest
      URL: ${local.mpi_operator_deployment_url}
      Status code: ${local.mpi_operator_manifest_status_code}
      Response: ${local.mpi_operator_manifest_content}
      EOT
    }
  }
}
