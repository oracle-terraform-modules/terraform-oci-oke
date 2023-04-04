# Copyright (c) 2021, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  gatekeeper_enabled       = var.gatekeeper_enabled && var.expected_node_count > 0
  gatekeeper_manifest      = one(data.helm_template.gatekeeper[*].manifest)
  gatekeeper_manifest_path = join("/", [local.helm_manifest_path, "gatekeeper.yaml"])
}

data "helm_template" "gatekeeper" {
  count        = local.gatekeeper_enabled ? 1 : 0
  chart        = "gatekeeper"
  repository   = "https://open-policy-agent.github.io/gatekeeper/charts"
  version      = var.gatekeeper_helm_version
  kube_version = var.kubernetes_version

  name             = "gatekeeper"
  namespace        = var.gatekeeper_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.gatekeeper_helm_values_files) > 0 ? [
    for path in var.gatekeeper_helm_values_files : file(path)
  ] : null

  # TODO Remove after merge: https://github.com/open-policy-agent/gatekeeper/pull/2593
  set {
    name  = "postInstall.labelNamespace.enabled"
    value = "false"
  }

  # TODO Remove after merge: https://github.com/open-policy-agent/gatekeeper/pull/2593
  set {
    name  = "postInstall.probeWebhook.enabled"
    value = "false"
  }

  dynamic "set" {
    for_each = var.gatekeeper_helm_values
    iterator = helm_value
    content {
      name  = helm_value.key
      value = helm_value.value
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([for path in var.gatekeeper_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.gatekeeper_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "gatekeeper" {
  count = local.gatekeeper_enabled ? 1 : 0

  triggers = {
    manifest_md5 = try(md5(local.gatekeeper_manifest), null)
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
    content     = local.gatekeeper_manifest
    destination = local.gatekeeper_manifest_path
  }

  provisioner "remote-exec" {
    inline = ["kubectl apply -f ${local.gatekeeper_manifest_path}"]
  }
}
