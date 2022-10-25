# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  tenancy_id       = coalesce(var.tenancy_id, var.tenancy_ocid)
  compartment_id   = coalesce(var.worker_compartment_id, var.compartment_id, var.compartment_ocid, local.tenancy_id)
  region           = coalesce(var.region, var.home_region)
  user_id          = var.user_id != "" ? var.user_id : var.current_user_ocid
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

  k8s_version_length = length(var.kubernetes_version)
  k8s_version_only   = substr(var.kubernetes_version, 1, local.k8s_version_length)

  kubeconfig          = try(yamldecode(lookup(data.oci_containerengine_cluster_kube_config.kube_config, "content", "")), { "error" : "yamldecode" })
  kubeconfig_clusters = try(lookup(local.kubeconfig, "clusters", []), [])
  kubeconfig_ca_cert  = try(lookup(lookup(local.kubeconfig_clusters[0], "cluster", {}), "certificate-authority-data", ""), "")
  cluster_ca_cert     = length(var.cluster_ca_cert) > 0 ? var.cluster_ca_cert : local.kubeconfig_ca_cert

  # Instance tags - variables + constant
  defined_tags  = merge(coalesce(var.defined_tags, {}), {})
  freeform_tags = merge(coalesce(var.freeform_tags, {}), { role = "worker" })

  # OKE managed node pool images
  node_pool_images = try(data.oci_containerengine_node_pool_option.np_options.sources, [{
    source_type = "IMAGE"
  }])

  parsed_images = {
    for k, v in local.node_pool_images : v.image_id => merge(
      try(element(regexall("OKE-(?P<k8s_version>[0-9\\.]+)-(?P<build>[0-9]+)", v.source_name), 0), { k8s_version = "none" }),
      {
        arch        = length(regexall("aarch64", v.source_name)) > 0 ? "aarch64" : "x86_64"
        image_type  = length(regexall("OKE", v.source_name)) > 0 ? "oke" : "platform"
        is_gpu      = length(regexall("GPU", v.source_name)) > 0 ? true : false
        os          = trimspace(replace(element(regexall("^[a-zA-Z-]+", v.source_name), 0), "-", " "))
        os_version  = element(regexall("[0-9\\.]+", v.source_name), 0)
        source_name = v.source_name
    })
  }

  image_ids = {
    x86_64   = [for k, v in local.parsed_images : k if v.arch == "x86_64"]
    aarch64  = [for k, v in local.parsed_images : k if v.arch == "aarch64"]
    oke      = [for k, v in local.parsed_images : k if v.image_type == "oke" && v.k8s_version == local.k8s_version_only]
    platform = [for k, v in local.parsed_images : k if v.image_type == "platform"]
    gpu      = [for k, v in local.parsed_images : k if v.is_gpu]
    nongpu   = [for k, v in local.parsed_images : k if !v.is_gpu]
  }

  # Filter worker_groups map variable for enabled entries
  worker_groups_enabled = {
    for k, v in var.worker_groups : k => v if lookup(v, "enabled", var.enabled)
  }

  # Number of nodes expected from enabled worker groups
  expected_node_count = (length(local.worker_groups_enabled) == 0 ? 0 :
  sum([for k, v in local.worker_groups_enabled : max(0, lookup(v, "size", local.size))]))

  # Filter worker_groups map variable for entries with image_id defined, returning a distinct list
  enabled_worker_group_image_ids = distinct(tolist([
    for v in local.worker_groups_enabled : v.image_id if contains(keys(v), "image_id")
  ]))

  # Intermediate worker image result from data source
  # TODO Finish implementing image OCID lookup to index OS information
  enabled_worker_group_images = data.oci_core_image.worker_images

  # Filter enabled worker_group map entries for node pools
  enabled_node_pools = {
    for k, v in local.worker_groups_enabled : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "node-pool"
  }

  # Filter enabled worker_group map entries for instance pools
  enabled_instance_configs = {
    for k, v in local.worker_groups_enabled : k => v
    if contains(["cluster-network", "instance-pool"],
    coalesce(lookup(v, "mode", "unknown"), local.mode))
  }

  # Filter enabled worker_group map entries for instance pools
  enabled_instance_pools = {
    for k, v in local.worker_groups_enabled : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "instance-pool"
  }

  # Filter enabled worker_group map entries for cluster networks
  enabled_cluster_networks = {
    for k, v in local.worker_groups_enabled : k => v
    if coalesce(lookup(v, "mode", "unknown"), local.mode) == "cluster-network"
  }

  # Intermediate reference to the enabled worker group NLBs to be reconciled
  enabled_worker_group_nlbs = tolist([
    for k, v in local.worker_groups_enabled : {
      for lb_k, lb_v in(contains(keys(v), "load_balancers") ? v.load_balancers : {}) : lb_k => lb_v
    } if contains(keys(v), "load_balancers")
  ])

  # Convenience output transformations

  # Group resource outputs
  cluster_networks_active = length(oci_core_cluster_network.cluster_networks) > 0 ? oci_core_cluster_network.cluster_networks : {}
  instance_pools_active   = length(oci_core_instance_pool.instance_pools) > 0 ? oci_core_instance_pool.instance_pools : {}
  node_pools_active       = length(oci_containerengine_node_pool.nodepools) > 0 ? oci_containerengine_node_pool.nodepools : {}

  worker_groups_active = merge(
    tomap(local.cluster_networks_active),
    tomap(local.instance_pools_active),
    tomap(local.node_pools_active),
  )
}