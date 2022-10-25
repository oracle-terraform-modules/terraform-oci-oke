# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  tenancy_id       = coalesce(var.tenancy_id, var.tenancy_ocid)
  compartment_id   = coalesce(var.worker_compartment_id, var.compartment_id, var.compartment_ocid, local.tenancy_id)
  region           = coalesce(var.region, var.home_region)
  mode             = coalesce(var.mode, "node-pool")
  size             = max(var.size, 0)
  shape            = coalesce(var.shape, "VM.Standard.E4.Flex")
  boot_volume_size = coalesce(var.boot_volume_size, 50)
  memory           = coalesce(var.memory, 16)
  ocpus            = coalesce(var.ocpus, 1)

  # SSH public key: base64-encoded PEM > raw PEM > file PEM > null
  ssh_public_key = (
    var.ssh_public_key != ""
    ? try(base64decode(var.ssh_public_key), var.ssh_public_key)
    : var.ssh_public_key_path != "none"
    ? file(var.ssh_public_key_path)
  : null)

  # Stable availability domain selection
  ads        = data.oci_identity_availability_domains.ad_list.availability_domains
  ad_numbers = local.ads != null ? sort(keys(local.ad_number_to_name)) : tolist([])
  ad_number_to_name = local.ads != null ? {
    for ad in local.ads : parseint(substr(ad.name, -1, -1), 10) => ad.name
  } : { -1 : "" } # Fallback handles failure when unavailable but not required
  first_ad_name = local.ad_number_to_name[1]

  k8s_version_length = length(var.k8s_version)
  k8s_version_only   = substr(var.k8s_version, 1, local.k8s_version_length)

  kubeconfig          = try(yamldecode(lookup(data.oci_containerengine_cluster_kube_config.kube_config, "content", "")), { "error" : "yamldecode" })
  kubeconfig_clusters = try(lookup(local.kubeconfig, "clusters", []), [])
  kubeconfig_ca_cert  = try(lookup(lookup(local.kubeconfig_clusters[0], "cluster", {}), "certificate-authority-data", ""), "")
  cluster_ca_cert     = length(var.cluster_ca_cert) > 0 ? var.cluster_ca_cert : local.kubeconfig_ca_cert

  # Instance tags - variables + constant
  defined_tags  = merge(coalesce(var.defined_tags, {}), {})
  freeform_tags = merge(coalesce(var.freeform_tags, {}), { role = "worker" })

  # OKE managed node pool images
  # 1. get a list of available images for this cluster
  # 2. filter by version
  # 3. if more than 1 image found for this version, pick the latest
  node_pool_image_ids = try(data.oci_containerengine_node_pool_option.np_options.sources, [{
    source_type = "IMAGE"
  }])

  # Filter worker_groups map variable for enabled entries
  enabled_worker_groups = {
    for k, v in var.worker_groups : k => v if lookup(v, "enabled", var.enabled)
  }

  # Filter worker_groups map variable for entries with image_id defined, returning a distinct list
  enabled_worker_group_image_ids = distinct(tolist([
    for v in local.enabled_worker_groups : v.image_id if contains(keys(v), "image_id")
  ]))

  # Intermediate worker image result from data source
  # TODO Finish implementing image OCID lookup to index OS information
  enabled_worker_group_images = data.oci_core_image.worker_images

  # Filter enabled worker_group map entries for node pools
  enabled_node_pools = {
    for k, v in local.enabled_worker_groups : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "node-pool"
  }

  # Filter enabled worker_group map entries for instance pools
  enabled_instance_configs = {
    for k, v in local.enabled_worker_groups : k => v
    if contains(["cluster-network", "instance-pool"],
    coalesce(lookup(v, "mode", "unknown"), local.mode))
  }

  # Filter enabled worker_group map entries for instance pools
  enabled_instance_pools = {
    for k, v in local.enabled_worker_groups : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "instance-pool"
  }

  # Filter enabled worker_group map entries for cluster networks
  enabled_cluster_networks = {
    for k, v in local.enabled_worker_groups : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "cluster-network"
  }

  # Intermediate reference to the enabled worker group NLBs to be reconciled
  enabled_worker_group_nlbs = tolist([
    for k, v in local.enabled_worker_groups : {
      for lb_k, lb_v in(contains(keys(v), "load_balancers") ? v.load_balancers : {}) : lb_k => lb_v
    } if contains(keys(v), "load_balancers")
  ])

  # Convenience output transformations
  node_pools_output = (
    length(oci_containerengine_node_pool.nodepools) > 0
    ? oci_containerengine_node_pool.nodepools
    : null
  )

  instance_pools_output = (
    length(oci_core_instance_pool.instance_pools) > 0
    ? oci_core_instance_pool.instance_pools
    : null
  )

  cluster_networks_output = (
    length(oci_core_cluster_network.cluster_networks) > 0
    ? oci_core_cluster_network.cluster_networks
    : null
  )

  result_groups_output = merge(
    local.node_pools_output,
    local.instance_pools_output,
    local.cluster_networks_output,
  )

  user_id = var.user_id != "" ? var.user_id : var.current_user_ocid
  worker_groups_ids = {
    for g in local.result_groups_output :
    coalesce(lookup(g, "name", ""), lookup(g, "display_name", ""), "unknown") => coalesce(lookup(g, "id", ""), "unknown")
  }
}