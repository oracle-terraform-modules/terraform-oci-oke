# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = local.worker_compartment_id
}

// Used to retrieve available worker node images, k8s versions, shapes...
data "oci_containerengine_node_pool_option" "np_options" {
  node_pool_option_id = coalesce(var.cluster_id, "all")
  compartment_id      = local.worker_compartment_id
}

// Used to retrieve cluster CA certificate
data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = var.cluster_id
}

data "oci_core_image" "worker_images" {
  count    = length(local.enabled_worker_pool_image_ids)
  image_id = local.enabled_worker_pool_image_ids[count.index]
}
