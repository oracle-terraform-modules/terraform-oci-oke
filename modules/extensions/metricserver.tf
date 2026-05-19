# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  metrics_server_enabled       = var.metrics_server_install && var.expected_node_count > 0
  metrics_server_manifest      = sensitive(one(data.helm_template.metrics_server[*].manifest))
  metrics_server_manifest_path = join("/", [local.yaml_manifest_path, "metrics_server.manifest.yaml"])
}

data "helm_template" "metrics_server" {
  count        = local.metrics_server_enabled ? 1 : 0
  chart        = "metrics-server"
  repository   = "https://kubernetes-sigs.github.io/metrics-server"
  version      = var.metrics_server_helm_version
  kube_version = var.kubernetes_version

  name             = "metrics-server"
  namespace        = var.metrics_server_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.metrics_server_helm_values_files) > 0 ? [
    for path in var.metrics_server_helm_values_files : file(path)
  ] : null

  set = concat(
    [for k, v in var.metrics_server_helm_values :
      {
        name  = k,
        value = v
      }
    ]
  )

  lifecycle {
    precondition {
      condition = alltrue([for path in var.metrics_server_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.metrics_server_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "metrics_server" {
  count = local.metrics_server_enabled ? 1 : 0

  triggers = {
    manifest_md5 = try(md5(local.metrics_server_manifest), null)
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
    content     = local.metrics_server_manifest
    destination = local.metrics_server_manifest_path
  }

  provisioner "remote-exec" {
    inline = compact([
      (contains(["kube-system", "default"], var.metrics_server_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.metrics_server_namespace)),
      format(local.kubectl_apply_server_file, local.metrics_server_manifest_path),
    ])
  }
}
