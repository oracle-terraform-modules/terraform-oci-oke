# Copyright (c) 2021, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  argocd_enabled       = var.argocd_install && var.expected_node_count > 0
  argocd_manifest      = sensitive(one(data.helm_template.argocd[*].manifest))
  argocd_manifest_path = join("/", [local.yaml_manifest_path, "argocd.yaml"])
}

data "helm_template" "argocd" {
  count        = local.argocd_enabled ? 1 : 0
  chart        = "argo-cd"
  repository   = "https://argoproj.github.io/argo-helm"
  version      = var.argocd_helm_version
  kube_version = var.kubernetes_version

  name             = "argocd"
  namespace        = var.argocd_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.argocd_helm_values_files) > 0 ? [
    for path in var.argocd_helm_values_files : file(path)
  ] : null

  set = concat(
    [for k, v in var.argocd_helm_values :
      {
        name  = k,
        value = v
      }
    ]
  )

  lifecycle {
    precondition {
      condition = alltrue([for path in var.argocd_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.argocd_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "argocd" {
  count = local.argocd_enabled ? 1 : 0

  triggers = {
    manifest_md5 = try(md5(local.argocd_manifest), null)
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
    content     = local.argocd_manifest
    destination = local.argocd_manifest_path
  }

  provisioner "remote-exec" {
    inline = [for c in compact([
      (contains(["kube-system", "default"], var.argocd_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.argocd_namespace)),
      format(local.kubectl_apply_server_file, local.argocd_manifest_path),
      ]) : format(local.output_log, c, "argocd")
    ]
  }
}
