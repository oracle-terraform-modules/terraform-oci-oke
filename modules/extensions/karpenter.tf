# Copyright (c) 2021, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  karpenter_enabled       = var.karpenter_install && var.expected_node_count > 0
  karpenter_repository    = "https://oracle.github.io/karpenter-provider-oci/charts"
  karpenter_chart         = "karpenter"
  karpenter_manifest      = sensitive(one(data.helm_template.karpenter[*].manifest))
  karpenter_manifest_path = join("/", [local.yaml_manifest_path, "karpenter.yaml"])
  karpenter_defaults = {
    defaults = {
      "settings.ociVcnIpNative"       = var.cni_type == "npn" ? true : false,
      "settings.clusterCompartmentId" = var.cluster_compartment_id
      "settings.vcnCompartmentId"     = var.vcn_compartment_id
      "settings.apiserverEndpoint"    = var.cluster_private_endpoint
    }
  }
}

data "helm_template" "karpenter" {
  count            = local.karpenter_enabled ? 1 : 0
  chart            = local.karpenter_chart
  repository       = local.karpenter_repository
  version          = var.karpenter_version
  kube_version     = var.kubernetes_version
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.karpenter_helm_values_files) > 0 ? [
    for path in var.karpenter_helm_values_files : file(path)
  ] : null

  set = concat(
    [ for k, v in merge(local.karpenter_defaults.defaults, var.karpenter_helm_values):
      {
        name  = k,
        value = v
      }
    ]
  )

  lifecycle {
    precondition {
      condition = alltrue([for path in var.karpenter_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.karpenter_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "karpenter" {
  count = local.karpenter_enabled ? 1 : 0

  triggers = {
    manifest_md5 = try(md5(local.karpenter_manifest), null)
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
    content     = local.karpenter_manifest
    destination = local.karpenter_manifest_path
  }

  provisioner "remote-exec" {
    inline = [for c in compact([
      (contains(["kube-system", "default"], var.karpenter_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.karpenter_namespace)),
      format(local.kubectl_apply_server_file, local.karpenter_manifest_path),
      ]) : format(local.output_log, c, "karpenter")
    ]
  }
}
