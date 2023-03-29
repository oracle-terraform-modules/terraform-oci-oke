# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  calico_helm_crds     = one(data.helm_template.calico[*].crds)
  calico_helm_manifest = one(data.helm_template.calico[*].manifest)

  calico_helm_crds_file     = join("/", [local.yaml_manifest_path, "calico.crds.yaml"])
  calico_helm_manifest_file = join("/", [local.yaml_manifest_path, "calico.manifest.yaml"])
  calico_helm_values_file   = join("/", [local.yaml_manifest_path, "calico.values.yaml"])
  calico_felix_config_file  = join("/", [local.yaml_manifest_path, "calico.felix.yaml"])

  calico_felix_config = {
    apiVersion = "crd.projectcalico.org/v1"
    kind       = "FelixConfiguration"
    metadata   = { name = "default" }
    spec = merge(
      {
        prometheusMetricsEnabled = var.prometheus_install
      },
      var.cni_type == "npn" ? {
        interfacePrefix       = "oci"
        chainInsertMode       = "Append"
        FeatureDetectOverride = "SNATFullyRandom=false,MASQFullyRandom=false,RestoreSupportsLock=false,IPIPDeviceIsL3=false"
        IpInIpEnabled         = false
        RemoveExternalRoutes  = false
        bpfEnabled            = false
        chainInsertMode       = "Append"
        interfacePrefix       = "oci"
        routeSource           = "WorkloadIPs"
        routeSyncDisabled     = true
        vxlanEnabled          = false
        xdpEnabled            = false
      } : {},
    )
  }

  calico_helm_values = {
    installation = {
      cni = {
        type = var.cni_type == "npn" ? "AzureVNET" : "Calico"
        ipam = {
          type = var.cni_type == "npn" ? "HostLocal" : "Calico"
        },
      },
      calicoNetwork = {
        bgp       = "Enabled"
        hostPorts = "Enabled"
        ipPools = var.cni_type == "npn" ? [] : [
          {
            cidr             = var.pods_cidr
            encapsulation    = "VXLANCrossSubnet"
            natOutgoing      = "Enabled"
            disableBGPExport = false #true
            nodeSelector     = "all()"
          },
        ]
        linuxDataplane = "Iptables" # Iptables*|BPF
        nodeAddressAutodetectionV4 = {
          kubernetes = "NodeInternalIP"
        }
      }
    }
  }

  calico_felix_config_yaml = yamlencode(local.calico_felix_config)
  calico_helm_values_yaml  = yamlencode(local.calico_helm_values)
}

data "helm_template" "calico" {
  count        = var.calico_install ? 1 : 0
  chart        = "tigera-operator"
  repository   = "https://docs.tigera.io/calico/charts"
  version      = "v${var.calico_helm_version}"
  kube_version = var.kubernetes_version

  name             = "calico"
  namespace        = var.calico_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = concat(
    [local.calico_helm_values_yaml],
    [for path in var.calico_helm_values_files : file(path)],
  )

  dynamic "set" {
    for_each = var.calico_helm_values
    iterator = helm_value
    content {
      name  = helm_value.key
      value = helm_value.value
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([for path in var.calico_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.calico_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "calico" {
  count = var.calico_install ? 1 : 0

  triggers = {
    helm_version     = var.calico_helm_version
    crds_md5         = try(md5(join("\n", local.calico_helm_crds)), null)
    felix_config_md5 = try(md5(local.calico_felix_config_yaml), null)
    manifest_md5     = try(md5(local.calico_helm_manifest), null)
    reapply          = var.calico_reapply ? uuid() : null
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
    content     = join("\n", local.calico_helm_crds)
    destination = local.calico_helm_crds_file
  }

  provisioner "file" {
    content     = local.calico_helm_manifest
    destination = local.calico_helm_manifest_file
  }

  provisioner "file" {
    content     = local.calico_felix_config_yaml
    destination = local.calico_felix_config_file
  }

  provisioner "file" {
    content     = local.calico_helm_values_yaml
    destination = local.calico_helm_values_file
  }

  provisioner "remote-exec" {
    inline = [for c in compact([
      (contains(["kube-system", "default"], var.calico_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.calico_namespace)),
      format(local.kubectl_apply_server_file, local.calico_helm_crds_file),
      format(local.kubectl_apply_file, local.calico_felix_config_file),
      format(local.kubectl_apply_server_file, local.calico_helm_manifest_file),
      ]) : format(local.output_log, c, "calico")
    ]
  }
}
