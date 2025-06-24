# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  dcgm_exporter_helm_crds_file     = join("/", [local.yaml_manifest_path, "dcgm_exporter.crds.yaml"])
  dcgm_exporter_helm_manifest_file = join("/", [local.yaml_manifest_path, "dcgm_exporter.manifest.yaml"])
  dcgm_exporter_helm_crds          = sensitive(one(data.helm_template.dcgm_exporter[*].crds))
  dcgm_exporter_helm_manifest      = sensitive(one(data.helm_template.dcgm_exporter[*].manifest))

  dcgm_exporter_scrape_config = [
    {
      job_name        = "gpu-metrics"
      scrape_interval = "10s"
      metrics_path    = "/metrics"
      scheme          = "http"
      kubernetes_sd_configs = [
        {
          role       = "endpoints"
          namespaces = { names = ["metrics"] }
          selectors  = [{ label = "app.kubernetes.io/component=dcgm-exporter" }]
        }
      ]
      relabel_configs = [
        {
          source_labels = ["__meta_kubernetes_pod_node_name"]
          action        = "replace"
          target_label  = "kubernetes_node"
        }
      ]
    }
  ]
}

data "helm_template" "dcgm_exporter" {
  count        = var.dcgm_exporter_install ? 1 : 0
  chart        = "dcgm-exporter"
  repository   = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  version      = var.dcgm_exporter_helm_version
  kube_version = var.kubernetes_version

  name             = "dcgm-exporter"
  namespace        = var.dcgm_exporter_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = length(var.dcgm_exporter_helm_values_files) > 0 ? [
    for path in var.dcgm_exporter_helm_values_files : file(path)
  ] : null

  set = concat(
    [ for k, v in var.dcgm_exporter_helm_values:
      {
        name  = k,
        value = v
      }
    ]
  )

  lifecycle {
    precondition {
      condition = alltrue([for path in var.dcgm_exporter_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.dcgm_exporter_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "dcgm_exporter" {
  count = var.dcgm_exporter_install ? 1 : 0

  triggers = {
    helm_version = var.dcgm_exporter_helm_version
    crds_md5     = try(md5(join("\n", local.dcgm_exporter_helm_crds)), null)
    manifest_md5 = try(md5(local.dcgm_exporter_helm_manifest), null)
    reapply      = var.dcgm_exporter_reapply ? uuid() : null
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
    content     = join("\n", local.dcgm_exporter_helm_crds)
    destination = local.dcgm_exporter_helm_crds_file
  }

  provisioner "file" {
    content     = local.dcgm_exporter_helm_manifest
    destination = local.dcgm_exporter_helm_manifest_file
  }

  provisioner "remote-exec" {
    inline = [for c in compact([
      (contains(["kube-system", "default"], var.dcgm_exporter_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.dcgm_exporter_namespace)),
      format(local.kubectl_apply_server_file, local.dcgm_exporter_helm_crds_file),
      format(local.kubectl_apply_server_file, local.dcgm_exporter_helm_manifest_file),
      ]) : format(local.output_log, c, "dcgm_exporter")
    ]
  }
}
