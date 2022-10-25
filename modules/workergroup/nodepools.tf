# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Node Pool groups defined in worker_groups
resource "oci_containerengine_node_pool" "node_pools" {
  # Create an OKE node pool resource for each enabled entry of the worker_groups map with that mode.
  for_each           = local.enabled_node_pools
  compartment_id     = each.value.compartment_id
  cluster_id         = var.cluster_id
  kubernetes_version = var.kubernetes_version
  name               = "${each.value.label_prefix}-${each.key}"
  defined_tags       = merge(local.defined_tags, contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
  freeform_tags      = merge(local.freeform_tags, contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })

  node_config_details {
    size                                = each.value.size
    is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit
    kms_key_id                          = var.volume_kms_key_id
    nsg_ids                             = each.value.worker_nsgs

    dynamic "placement_configs" {
      # Define each configured availability domain for placement, with bounds on # available
      # Configured AD numbers e.g. [1,2,3] are converted into tenancy/compartment-specific names
      iterator = ad_number
      for_each = (contains(keys(each.value), "placement_ads")
        ? tolist(setintersection(each.value.placement_ads, local.ad_numbers))
      : local.ad_numbers)

      content {
        availability_domain = lookup(local.ad_number_to_name, ad_number.value, local.first_ad_name)
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

    defined_tags = merge(
      local.defined_tags,
      lookup(each.value, "defined_tags", {}),
    )
    freeform_tags = merge(local.freeform_tags, contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })
  }

  node_metadata = {
    apiserver_host           = var.apiserver_private_host
    kubedns_svc_ip           = var.cluster_dns
    oke-kubeproxy-proxy-mode = var.kubeproxy_mode
    user_data                = data.cloudinit_config.worker_once.rendered
  }

  node_shape = each.value.shape
  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
    content {
      ocpus = each.value.ocpus
      memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
        (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
      )
    }
  }

  dynamic "node_source_details" {
    for_each = length(local.parsed_images) > 0 ? [1] : []
    content {
      source_type             = local.node_pool_images[0].source_type
      boot_volume_size_in_gbs = each.value.boot_volume_size
      image_id = (each.value.image_type == "custom" ? each.value.image_id
        : element(tolist(setintersection([
          lookup(local.image_ids, each.value.image_type, null),
          length(regexall("GPU", each.value.shape)) > 0 ? local.image_ids.gpu : local.image_ids.nongpu,
          length(regexall("A1", each.value.shape)) > 0 ? local.image_ids.aarch64 : local.image_ids.x86_64,
          [for k, v in local.parsed_images : k
            if length(regexall(v.os, each.value.os)) > 0
            && trimprefix(v.os_version, each.value.os_version) != v.os_version
          ],
      ]...)), 0))
    }
  }

  ssh_public_key = (var.ssh_public_key != "") ? var.ssh_public_key : (var.ssh_public_key_path != "none") ? file(var.ssh_public_key_path) : ""

  lifecycle { # prevent resources changes for changed fields
    ignore_changes = [
      kubernetes_version, # e.g. if changed as part of an upgrade
      name, defined_tags, freeform_tags,
      node_metadata["user_data"],               # templated cloud-init
      node_config_details["placement_configs"], # dynamic placement configs
      node_source_details,                      # dynamic image lookup
    ]
  }

  dynamic "initial_node_labels" {
    for_each = merge(var.node_labels, each.value.node_labels)
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
}