# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = local.compartment_id
}

// Used to retrieve available worker node images, k8s versions, shapes...
data "oci_containerengine_node_pool_option" "np_options" {
  node_pool_option_id = coalesce(var.cluster_id, "all")
  compartment_id      = local.compartment_id
}

// Used to retrieve cluster CA certificate
data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = var.cluster_id
}

data "oci_core_image" "worker_images" {
  count    = length(local.enabled_worker_group_image_ids)
  image_id = local.enabled_worker_group_image_ids[count.index]
}

data "oci_core_cluster_network_instances" "cn_instances" {
  for_each           = local.cluster_networks_active
  compartment_id     = local.compartment_id
  cluster_network_id = each.value.id
}

data "oci_core_instance_pool_instances" "ip_instances" {
  for_each         = local.instance_pools_active
  compartment_id   = local.compartment_id
  instance_pool_id = each.value.id
}
