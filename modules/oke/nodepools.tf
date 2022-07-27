# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_containerengine_node_pool" "nodepools" {
  for_each       = var.node_pools
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_id
  depends_on     = [oci_containerengine_cluster.k8s_cluster]

  kubernetes_version = var.cluster_kubernetes_version
  name               = var.label_prefix == "none" ? each.key : "${var.label_prefix}-${each.key}"

  freeform_tags = var.freeform_tags["node_pool"]

  node_config_details {

    is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit

    kms_key_id = var.node_pool_volume_kms_key_id

    # iterating over ADs
    dynamic "placement_configs" {
      iterator = ad_iterator
      for_each = local.ad_names
      content {
        availability_domain = ad_iterator.value
        subnet_id           = var.cluster_subnets["workers"]
      }
    }
    nsg_ids = var.worker_nsgs

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
        max_pods_per_node = var.max_pods_per_node
        pod_nsg_ids       = var.pod_nsgs
        pod_subnet_ids    = tolist([var.cluster_subnets["pods"]])
      }
    }

    # allow zero-sized node pools
    size = max(0, lookup(each.value, "node_pool_size", 0))
  }

  # setting shape
  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", lookup(each.value, "shape", "VM.Standard.E4.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(each.value, "ocpus", 1))
      memory_in_gbs = (lookup(each.value, "memory", 16) / lookup(each.value, "ocpus", 1)) > 64 ? (lookup(each.value, "ocpus", 1) * 64) : lookup(each.value, "memory", 16)
    }
  }

  # cloud-init
  node_metadata = {
    user_data = var.cloudinit_nodepool_common == "" && lookup(var.cloudinit_nodepool, each.key, null) == null ? data.cloudinit_config.worker.rendered : lookup(var.cloudinit_nodepool, each.key, null) != null ? filebase64(lookup(var.cloudinit_nodepool, each.key, null)) : filebase64(var.cloudinit_nodepool_common)
  }

  # optimized OKE images
  dynamic "node_source_details" {
    for_each = var.node_pool_image_type == "oke" ? [1] : []
    content {
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", 50)
      # check for GPU,A1 and other shapes. In future, if some other shapes or images are added, we need to modify
      image_id = (var.node_pool_image_type == "oke" && length(regexall("GPU|A1", lookup(each.value, "shape"))) == 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pool_os_version}-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0)) : (var.node_pool_image_type == "oke" && length(regexall("GPU", lookup(each.value, "shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pool_os_version}-Gen[0-9]-GPU-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0)) : (var.node_pool_image_type == "oke" && length(regexall("A1", lookup(each.value, "shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pool_os_version}-aarch64-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0)) : null

      source_type = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].source_type
    }
  }

  # OCI platform images
  dynamic "node_source_details" {
    for_each = var.node_pool_image_type == "platform" ? [1] : []
    content {
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", 50)
      # check for GPU,A1 and other shapes. In future, if some other shapes or images are added, we need to modify
      image_id = (var.node_pool_image_type == "platform" && length(regexall("GPU|A1", lookup(each.value, "shape"))) == 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.node_pool_os_version}-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0)) : (var.node_pool_image_type == "platform" && length(regexall("GPU", lookup(each.value, "shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.node_pool_os_version}-Gen[0-9]-GPU-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0)) : (var.node_pool_image_type == "platform" && length(regexall("A1", lookup(each.value, "shape"))) > 0) ? (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.node_pool_os_version}-aarch64-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0)) : null

      source_type = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].source_type
    }
  }

  # custom images 
  dynamic "node_source_details" {
    for_each = var.node_pool_image_type == "custom" ? [1] : []
    content {
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", 50)
      image_id                = var.node_pool_image_id
      source_type             = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].source_type
    }
  }
  node_shape = lookup(each.value, "shape", "VM.Standard.E4.Flex")

  ssh_public_key = (var.ssh_public_key != "") ? var.ssh_public_key : (var.ssh_public_key_path != "none") ? file(var.ssh_public_key_path) : ""

  # do not destroy the node pool if the kubernetes version has changed as part of the upgrade

  lifecycle {
    ignore_changes = [kubernetes_version]
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
