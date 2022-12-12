# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# The cluster autoscaler pods are deployed to the autoscaler node pool
resource "oci_containerengine_node_pool" "autoscaler_pool" {
  for_each       = var.enable_cluster_autoscaler == true ? var.autoscaler_pools : {}
  cluster_id     = oci_containerengine_cluster.k8s_cluster.id
  compartment_id = var.compartment_id
  depends_on     = [oci_containerengine_cluster.k8s_cluster]

  kubernetes_version = var.cluster_kubernetes_version
  name               = var.label_prefix == "none" ? each.key : "${var.label_prefix}-${each.key}"

  freeform_tags = merge(var.freeform_tags["node_pool"], { app = "cluster-autoscaler", pool = "autoscaler" })
  defined_tags  = merge(var.defined_tags["node_pool"], { "oke.pool" = "autoscaler" })

  node_config_details {

    is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit

    kms_key_id = var.node_pool_volume_kms_key_id

    # iterating over ADs
    dynamic "placement_configs" {
      iterator = ad_iterator
      for_each = [for n in lookup(each.value, "placement_ads", local.ad_numbers) :
      local.ad_number_to_name[n]]
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
        # pick the 1st pod nsg here until https://github.com/oracle/terraform-provider-oci/issues/1662 is clarified and resolved
        pod_nsg_ids    = element(var.pod_nsgs, 0)
        pod_subnet_ids = tolist([var.cluster_subnets["pods"]])
      }
    }

    size = 1

    freeform_tags = merge(var.freeform_tags["node"], { app = "cluster-autoscaler", pool = "autoscaler" })

    # hardcoded defined tags are used to determine dynamic group membership and permissions
    defined_tags = merge(var.defined_tags["node"], { "oke.pool" = "autoscaler" })
  }

  # setting shape
  node_shape = "VM.Standard.E4.Flex"

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 32
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

      # image fixed to E4.flex, no need to lookup
      image_id    = (element([for source in local.node_pool_image_ids : source.image_id if length(regexall("Oracle-Linux-${var.node_pool_os_version}-20[0-9]*.*-OKE-${local.k8s_version_only}", source.source_name)) > 0], 0))
      source_type = data.oci_containerengine_node_pool_option.node_pool_options.sources[0].source_type
    }
  }

  # OCI platform images
  dynamic "node_source_details" {
    for_each = var.node_pool_image_type == "platform" ? [1] : []
    content {
      boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", 50)
      # image fixed to E4.flex, no need to lookup
      image_id    = element([for source in local.node_pool_image_ids : source.image_id if length(regexall("^(Oracle-Linux-${var.node_pool_os_version}-\\d{4}.\\d{2}.\\d{2}-[0-9]*)$", source.source_name)) > 0], 0)
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

  ssh_public_key = (var.ssh_public_key != "") ? var.ssh_public_key : (var.ssh_public_key_path != "none") ? file(var.ssh_public_key_path) : ""

  # do not destroy the node pool if the kubernetes version has changed as part of the upgrade
  lifecycle {
    ignore_changes = [kubernetes_version]
  }

  # initial node labels for the autoscaler pool
  initial_node_labels {
    key   = "app"
    value = "cluster-autoscaler"
  }
}
