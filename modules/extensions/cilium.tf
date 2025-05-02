# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  cilium_helm_crds_file            = join("/", [local.yaml_manifest_path, "cilium.crds.yaml"])
  cilium_helm_manifest_file        = join("/", [local.yaml_manifest_path, "cilium.manifest.yaml"])
  cilium_helm_values_file          = join("/", [local.yaml_manifest_path, "cilium.values.yaml"])
  cilium_helm_values_override_file = join("/", [local.yaml_manifest_path, "cilium.values-override.yaml"])
  cilium_net_attach_def_file       = join("/", [local.yaml_manifest_path, "cilium.net_attach_def.yaml"])
  cilium_veth_config_map_file      = join("/", [local.yaml_manifest_path, "cilium.cni_config_map.yaml"])

  cilium_helm_crds            = one(data.helm_template.cilium[*].crds)
  cilium_helm_values_override = one(data.helm_template.cilium[*].values)

  cilium_helm_repository = "https://helm.cilium.io"

  cilium_vxlan_cni = {
    install   = true
    exclusive = true # !var.multus_install
  }

  cilium_helm_values = {
    annotateK8sNode = true
    cluster = {
      name = "oke-${var.state_id}"
      id   = 1
    }
    clustermesh = {
      useAPIServer = false
      apiserver = {
        kvstoremesh = {
          enabled = false
        }
      }
    }
    cni                             = local.cilium_vxlan_cni
    installNoConntrackIptablesRules = false
    ipam                            = { mode = "kubernetes" }
    kubeProxyReplacement            = false
    k8sServiceHost                  = var.cluster_private_endpoint
    k8sServicePort                  = "6443"
    pmtuDiscovery                   = { enabled = true }
    rollOutCiliumPods               = true
    tunnelProtocol                  = local.cilium_tunnel

    hubble = {
      metrics = {
        dashboards = { enabled = var.prometheus_install }
        # serviceMonitor = { enabled = var.prometheus_enabled }
      }
      relay = { enabled = true }
      ui    = { enabled = true }
    }

    k8s = {
      requireIPv4PodCIDR = true # wait for Kubernetes to provide the PodCIDR (ipam kubernetes)
    }

    # Prometheus metrics

    operator = {
      prometheus = {
        enabled = var.prometheus_install
        # serviceMonitor = { enabled = var.prometheus_enabled }
      }
    }
  }

  # TODO Support Flannel w/ generic-veth & tunnel disabled
  cilium_tunnel = "vxlan" # var.cni_type == "flannel" ? "disabled" : "vxlan"

  cilium_flannel_cni = {
    install      = true
    chainingMode = "generic-veth"
    configMap    = "cni-configuration"
    customConf   = var.cni_type == "flannel"
    exclusive    = !var.multus_install
  }

  cilium_net_attach_def_conf = {
    cniVersion = "0.3.1"
    name       = "cilium"
    plugins = [
      {
        cniVersion = "0.3.1"
        name       = "cilium"
        type       = "cilium-cni"
      },
      {
        name = "cilium-sbr"
        type = "sbr"
      }
    ],
  }

  cilium_net_attach_def = {
    apiVersion = "k8s.cni.cncf.io/v1"
    kind       = "NetworkAttachmentDefinition"
    metadata   = { name = "cilium" }
    spec       = { config = jsonencode(local.cilium_net_attach_def_conf) }
  }

  cilium_veth_conf = {
    cniVersion = "0.3.1"
    name       = "cbr0"
    "plugins" = [
      {
        type = "flannel"
        delegate = {
          hairpinMode      = true
          isDefaultGateway = true
        }
      },
      {
        type         = "portmap"
        capabilities = { portMappings = true }
      },
      { type = "cilium-cni" },
    ]
  }

  cilium_veth_config_map = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "cni-configuration"
      namespace = var.cilium_namespace
    }
    data = { "cni-config" = jsonencode(local.cilium_veth_conf) }
  }

  cilium_net_attach_def_yaml       = yamlencode(local.cilium_net_attach_def)
  cilium_veth_config_map_yaml      = yamlencode(local.cilium_veth_config_map)
  cilium_helm_values_yaml          = yamlencode(merge(local.cilium_helm_values, var.cilium_helm_values))
  cilium_helm_values_override_yaml = local.cilium_helm_values_override != null ? join("\n", local.cilium_helm_values_override) : ""
}

data "helm_template" "cilium" {
  count        = var.cilium_install ? 1 : 0
  chart        = "cilium"
  repository   = local.cilium_helm_repository
  version      = var.cilium_helm_version
  kube_version = var.kubernetes_version

  name             = "cilium"
  namespace        = var.cilium_namespace
  create_namespace = true
  include_crds     = true
  skip_tests       = true
  values = concat(
    [local.cilium_helm_values_yaml],
    [for path in var.cilium_helm_values_files : file(path)],
  )

  lifecycle {
    precondition {
      condition = alltrue([for path in var.cilium_helm_values_files : fileexists(path)])
      error_message = format("Missing Helm values files in configuration: %s",
        jsonencode([for path in var.cilium_helm_values_files : path if !fileexists(path)])
      )
    }
  }
}

resource "null_resource" "cilium" {
  count      = var.cilium_install ? 1 : 0
  depends_on = [null_resource.prometheus]

  triggers = {
    helm_version = var.cilium_helm_version
    crds_md5     = try(md5(join("\n", local.cilium_helm_crds)), null)
    manifest_md5 = try(md5(local.cilium_helm_values_override_yaml), null)
    reapply      = var.cilium_reapply ? uuid() : null
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
    content     = join("\n", local.cilium_helm_crds)
    destination = local.cilium_helm_crds_file
  }

  provisioner "file" {
    content     = local.cilium_helm_values_override_yaml
    destination = local.cilium_helm_values_override_file
  }

  # provisioner "file" {
  #   content     = local.cilium_net_attach_def_yaml
  #   destination = local.cilium_net_attach_def_file
  # }

  # provisioner "file" {
  #   content     = local.cilium_veth_config_map_yaml
  #   destination = local.cilium_veth_config_map_file
  # }

  provisioner "remote-exec" {
    inline = [for c in compact([
      # Create namespace if non-standard and missing
      (contains(["kube-system", "default"], var.cilium_namespace) ? null
      : format(local.kubectl_create_missing_ns, var.cilium_namespace)),

      # Install CRDs first
      format(local.kubectl_apply_server_ns_file, var.cilium_namespace, local.cilium_helm_crds_file),

      # Install full manifest
      format(local.helm_upgrade_install, "cilium", "cilium", local.cilium_helm_repository, var.cilium_helm_version, var.cilium_namespace, local.cilium_helm_values_override_file),

      # Install Network Attachment Definition when Multus is enabled
      # var.multus_install ? format(local.kubectl_apply_file, local.cilium_net_attach_def_file) : null,

      # Install CNI ConfigMap for Flannel
      # var.cni_type == "flannel" ? format(local.kubectl_apply_file, local.cilium_veth_config_map_file) : null,
      ]) : format(local.output_log, c, "cilium")
    ]
  }

  lifecycle {
    precondition {
      condition     = var.cni_type == "flannel"
      error_message = "Incompatible cni_type for installation - must be 'flannel'."
    }
  }
}