# Copyright 2017, 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Node Pool groups defined in worker_groups
resource "oci_containerengine_node_pool" "nodepools" {
  # Create an OKE node pool resource for each enabled entry of the worker_groups map with that mode.
  for_each           = local.enabled_node_pools
  compartment_id     = lookup(each.value, "compartment_id", local.compartment_id)
  cluster_id         = var.cluster_id
  kubernetes_version = var.k8s_version
  name               = join("-", compact([lookup(each.value, "label_prefix", var.label_prefix), each.key]))
  defined_tags       = merge(coalesce(local.defined_tags, {}), contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
  freeform_tags      = merge(coalesce(local.freeform_tags, {}), contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })

  node_config_details {
    size                                = max(0, lookup(each.value, "size", local.size))
    is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit
    kms_key_id                          = var.volume_kms_key_id

    dynamic "placement_configs" {
      # Define each configured availability domain for placement, with bounds on # available
      # Configured AD numbers e.g. [1,2,3] are converted into tenancy/compartment-specific names
      iterator = ad_number
      for_each = (contains(keys(each.value), "placement_ads")
        ? tolist(setintersection(each.value.placement_ads, local.ad_numbers))
      : local.ad_numbers)

      content {
        availability_domain = lookup(local.ad_number_to_name, ad_number.value, local.first_ad_name)
        subnet_id           = lookup(each.value, "primary_subnet_id", var.primary_subnet_id)
      }
    }

    nsg_ids = contains(keys(each.value), "worker_nsg_ids") ? each.value.nsg_ids : var.worker_nsg_ids

    # flannel requires cni type only
    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "flannel" ? [1] : []
      content {
        cni_type = "FLANNEL_OVERLAY"
      }
    }

    # native requires max pods/node, nsg ids, subnet ids
    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "npn" ? [1] : []
      content {
        cni_type          = "OCI_VCN_IP_NATIVE"
        max_pods_per_node = min(max(var.max_pods_per_node, 1), 110)
        # pick the 1st pod nsg here until https://github.com/oracle/terraform-provider-oci/issues/1662 is clarified and resolved
        pod_nsg_ids = slice(
          lookup(each.value, "pod_nsg_ids", var.pod_nsg_ids),
          0, min(1, length(lookup(each.value, "pod_nsg_ids", var.pod_nsg_ids)))
        )
        pod_subnet_ids = tolist([coalesce(lookup(each.value, "pod_subnet_id", var.pod_subnet_id), var.primary_subnet_id)])
      }
    }

    defined_tags  = merge(coalesce(local.defined_tags, {}), contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
    freeform_tags = merge(coalesce(local.freeform_tags, {}), contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })
  }

  # cloud-init
  node_metadata = {
    user_data = data.cloudinit_config.worker_np.rendered
  }

  node_shape = lookup(each.value, "shape", local.shape)
  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", lookup(each.value, "shape", local.shape))) > 0 ? [1] : []
    content {
      ocpus = max(1, lookup(each.value, "ocpus", local.ocpus))
      memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
        (lookup(each.value, "memory", local.memory) / lookup(each.value, "ocpus", local.ocpus)) > 64
        ? (lookup(each.value, "ocpus", local.ocpus) * 64)
        : lookup(each.value, "memory", local.memory)
      )
    }
  }

  # Optimized OKE images (recommended over platform images)
  dynamic "node_source_details" {
    for_each = (var.image_type == "oke" && length(local.node_pool_image_ids) > 0) ? [1] : []
    content {
      source_type             = local.node_pool_image_ids[0].source_type
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", local.boot_volume_size)
      # check for GPU,A1 and other shapes. In future, if some other shapes or images are added, we need to modify
      image_id = ((var.image_type == "oke" && length(regexall("GPU|A1", lookup(each.value, "shape", local.shape))) == 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.os_version}-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0))
        : (var.image_type == "oke" && length(regexall("GPU", lookup(each.value, "shape", local.shape))) > 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.os_version}-Gen[0-9]-GPU-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0))
        : (var.image_type == "oke" && length(regexall("A1", lookup(each.value, "shape", local.shape))) > 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.os_version}-aarch64-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0))
        : null
      )
    }
  }

  # OCI platform images
  dynamic "node_source_details" {
    for_each = (var.image_type == "platform" && length(local.node_pool_image_ids) > 0) ? [1] : []
    content {
      source_type             = local.node_pool_image_ids[0].source_type
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", local.boot_volume_size)
      # check for GPU,A1 and other shapes. In future, if some other shapes or images are added, we need to modify
      image_id = (var.image_type == (
        "platform" && length(regexall("GPU|A1", lookup(each.value, "shape", local.shape))) == 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.os_version}-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0))
        : (var.image_type == "platform" && length(regexall("GPU", lookup(each.value, "shape", local.shape))) > 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.os_version}-Gen[0-9]-GPU-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0))
        : (var.image_type == "platform" && length(regexall("A1", lookup(each.value, "shape", local.shape))) > 0)
        ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.os_version}-aarch64-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0))
        : null
      )
    }
  }

  # Custom images
  dynamic "node_source_details" {
    for_each = (var.image_type == "custom" || length(local.node_pool_image_ids) == 0) ? [1] : []
    content {
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", local.boot_volume_size)
      image_id                = lookup(each.value, "image_id", var.image_id)
      source_type             = "image"
    }
  }

  ssh_public_key = (var.ssh_public_key != "") ? var.ssh_public_key : (var.ssh_public_key_path != "none") ? file(var.ssh_public_key_path) : ""

  # do not destroy the node pool if the kubernetes version has changed as part of the upgrade
  lifecycle {
    ignore_changes = [
      kubernetes_version,
      name, defined_tags, freeform_tags,
      node_metadata["user_data"],               # templated cloud-init
      node_config_details["placement_configs"], # dynamic placement configs
      node_source_details                       # dynamic image lookup
    ]
  }

  # initial node labels for the different node pools
  dynamic "initial_node_labels" {
    for_each = lookup(each.value, "label", "") != "" ? each.value.label : {}
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
}