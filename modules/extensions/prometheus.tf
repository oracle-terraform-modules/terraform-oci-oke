# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  prometheus_enabled            = var.prometheus_enabled && var.expected_node_count > 0
  prometheus_helm_crds          = one(data.helm_template.prometheus[*].crds)
  prometheus_helm_manifest      = one(data.helm_template.prometheus[*].manifest)
  prometheus_helm_crds_file     = join("/", [local.helm_manifest_path, "prometheus_crds.yaml"])
  prometheus_helm_manifest_file = join("/", [local.helm_manifest_path, "prometheus_manifest.yaml"])
}

data "helm_template" "prometheus" {
  count        = local.prometheus_enabled ? 1 : 0
  chart        = "kube-prometheus-stack"
  repository   = "https://prometheus-community.github.io/helm-charts"
  version      = var.prometheus_helm_version
  kube_version = var.kubernetes_version

  name             = "prometheus"
  namespace        = var.prometheus_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.prometheus_helm_values_files) > 0 ? [
    for path in var.prometheus_helm_values_files : file(path)
  ] : null

  set {
    name  = "podSecurityPolicy.enabled"
    value = "false"
  }

  dynamic "set" {
    for_each = var.prometheus_helm_values
    iterator = helm_value
    content {
      name  = helm_value.key
      value = helm_value.value
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([for path in var.prometheus_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.prometheus_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "prometheus" {
  count = local.prometheus_enabled ? 1 : 0

  triggers = {
    manifest_md5 = try(md5(local.prometheus_helm_manifest), null)
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
    inline = ["mkdir -p ${local.helm_manifest_path}"]
  }

  provisioner "file" {
    content     = join("\n", local.prometheus_helm_crds)
    destination = local.prometheus_helm_crds_file
  }

  provisioner "file" {
    content     = local.prometheus_helm_manifest
    destination = local.prometheus_helm_manifest_file
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply --force-conflicts=true --server-side -f ${local.prometheus_helm_crds_file}",
      "kubectl apply --force-conflicts=true --server-side -f ${local.prometheus_helm_manifest_file}",
    ]
  }
}
