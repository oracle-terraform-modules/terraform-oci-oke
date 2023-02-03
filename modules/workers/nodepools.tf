# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Node Pool groups defined in worker_pools
resource "oci_containerengine_node_pool" "workers" {
  # Create an OKE node pool resource for each enabled entry of the worker_pools map with that mode.
  for_each           = local.enabled_node_pools
  cluster_id         = var.cluster_id
  compartment_id     = each.value.compartment_id
  defined_tags       = each.value.defined_tags
  freeform_tags      = each.value.freeform_tags
  kubernetes_version = var.kubernetes_version
  name               = each.key
  node_shape         = each.value.shape
  ssh_public_key     = var.ssh_public_key

  node_config_details {
    size                                = each.value.size
    is_pv_encryption_in_transit_enabled = each.value.pv_transit_encryption
    kms_key_id                          = each.value.volume_kms_key_id
    nsg_ids                             = each.value.nsg_ids
    defined_tags                        = each.value.defined_tags
    freeform_tags                       = each.value.freeform_tags

    dynamic "placement_configs" {
      for_each = each.value.availability_domains
      iterator = ad

      content {
        availability_domain = ad.value
        subnet_id           = each.value.subnet_id
      }
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "flannel" ? [1] : []
      content { # Flannel requires cni type only
        cni_type = "FLANNEL_OVERLAY"
      }
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "npn" ? [1] : []
      content { # VCN-Native requires max pods/node, nsg ids, subnet ids
        cni_type          = "OCI_VCN_IP_NATIVE"
        max_pods_per_node = min(max(var.max_pods_per_node, 1), 110)
        # pick the 1st pod nsg here until https://github.com/oracle/terraform-provider-oci/issues/1662 is clarified and resolved
        pod_nsg_ids    = slice(each.value.pod_nsg_ids, 0, min(1, length(each.value.pod_nsg_ids)))
        pod_subnet_ids = tolist([coalesce(each.value.pod_subnet_id, var.subnet_id)])
      }
    }
  }

  node_metadata = {
    apiserver_host           = var.apiserver_private_host
    kubedns_svc_ip           = var.cluster_dns
    oke-kubeproxy-proxy-mode = var.kubeproxy_mode
    user_data                = lookup(lookup(data.cloudinit_config.workers, each.key, {}), "rendered", "")
  }

  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
    content {
      ocpus = each.value.ocpus
      memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
        (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
      )
    }
  }

  node_source_details {
    boot_volume_size_in_gbs = each.value.boot_volume_size
    image_id                = each.value.image_id
    source_type             = "image"
  }

  lifecycle { # prevent resources changes for changed fields
    ignore_changes = [
      kubernetes_version, # e.g. if changed as part of an upgrade
      name, defined_tags, freeform_tags,
      node_metadata["user_data"],               # templated cloud-init
      node_config_details["placement_configs"], # dynamic placement configs
      node_source_details,                      # dynamic image lookup
    ]

    precondition {
      condition     = coalesce(each.value.image_id, "none") != "none"
      error_message = "Missing image_id for pool ${each.key}. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'oke' or 'platform'."
    }
  }

  dynamic "initial_node_labels" {
    for_each = each.value.node_labels
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
}