# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # Stable availability domain selection
  ads        = data.oci_identity_availability_domains.ad_list.availability_domains
  ad_numbers = local.ads != null ? sort(keys(local.ad_number_to_name)) : []
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
  defined_tags  = coalesce(var.defined_tags, {})
  freeform_tags = merge(coalesce(var.freeform_tags, {}), { "role" = "worker" })

  # OKE managed node pool images
  node_pool_images = try(data.oci_containerengine_node_pool_option.np_options.sources, [{
    source_type = "IMAGE"
  }])

  # Parse platform/operating system information from node pool image names
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

  worker_pools_default = {
    mode             = var.mode
    size             = var.size
    shape            = var.shape
    image_id         = var.image_id
    image_type       = var.image_type
    os               = var.os
    os_version       = var.os_version
    boot_volume_size = var.boot_volume_size
    memory           = var.memory
    ocpus            = var.ocpus
    compartment_id   = local.worker_compartment_id
    subnet_id        = var.subnet_id
    pod_subnet_id    = var.pod_subnet_id
    pod_nsgs         = var.pod_nsg_ids
    worker_nsgs      = var.worker_nsg_ids
    assign_public_ip = var.assign_public_ip
    label_prefix     = var.label_prefix # TODO Deprecate
    node_labels      = {}
  }

  # Filter worker_pools map variable for enabled entries
  worker_pools_enabled = {
    for k, v in var.worker_pools : k => merge(local.worker_pools_default, v) if lookup(v, "enabled", var.enabled)
  }

  worker_compartments = distinct(compact([for k, v in local.worker_pools_enabled : lookup(v, "compartment_id", "")]))

  # Number of nodes expected from enabled worker pools
  expected_node_count = length(local.worker_pools_enabled) == 0 ? 0 : sum([for k, v in local.worker_pools_enabled : lookup(v, "size", 0)])

  # Filter worker_pools map variable for entries with image_id defined, returning a distinct list
  enabled_worker_pool_image_ids = distinct([
    for v in local.worker_pools_enabled : v.image_id if contains(keys(v), "image_id")
  ])

  # Intermediate worker image result from data source
  enabled_worker_pool_images = data.oci_core_image.worker_images

  # Filter enabled worker_pool map entries for node pools
  enabled_node_pools = {
    for k, v in local.worker_pools_enabled : k => v if lookup(v, "mode", "") == "node-pool"
  }

  # Filter enabled worker_pool map entries for instance pools
  enabled_instance_configs = {
    for k, v in local.worker_pools_enabled : k => v
    if contains(["cluster-network", "instance-pool"], lookup(v, "mode", ""))
  }

  # Filter enabled worker_pool map entries for instance pools
  enabled_instance_pools = {
    for k, v in local.worker_pools_enabled : k => v if lookup(v, "mode", "") == "instance-pool"
  }

  # Filter enabled worker_pool map entries for cluster networks
  enabled_cluster_networks = {
    for k, v in local.worker_pools_enabled : k => v if lookup(v, "mode", "") == "cluster-network"
  }

  # Worker pool OCI resources enriched with desired/custom parameters
  worker_node_pools       = { for k, v in oci_containerengine_node_pool.node_pools : k => merge(v, lookup(local.worker_pools_enabled, k, {})) }
  worker_instance_pools   = { for k, v in oci_core_instance_pool.instance_pools : k => merge(v, lookup(local.worker_pools_enabled, k, {})) }
  worker_cluster_networks = { for k, v in oci_core_cluster_network.cluster_networks : k => merge(v, lookup(local.worker_pools_enabled, k, {})) }

  # Intermediate reference to the enabled worker pool NLBs to be reconciled
  enabled_worker_pool_nlbs = [
    for k, v in local.worker_pools_enabled : {
      for lb_k, lb_v in(contains(keys(v), "load_balancers") ? v.load_balancers : {}) : lb_k => lb_v
    } if contains(keys(v), "load_balancers")
  ]

  # Sanitized worker_pools output; some conditionally-used defaults would be misleading
  worker_pools_enabled_out = {
    for k, v in local.worker_pools_enabled : k => { for a, b in v : a => b
      if a != "enabled"                                                                # implied
      && !(a == "node_labels" && b == {})                                              # exclude empty
      && !(contains(["os", "os_version"], a) && v.image_type == "custom")              # unused defaults for custom
      && !(contains(["pod_nsgs", "pod_subnet_id"], a) && var.cni_type != "npn")        # unused defaults for NPN
      && !(contains(["ocpus", "memory"], a) && length(regexall("Flex", v.shape)) == 0) # unused defaults for non-Flex shapes
    }
  }

  # Group resource outputs
  worker_pools_active = merge(
    local.worker_cluster_networks,
    local.worker_instance_pools,
    local.worker_node_pools,
  )
}
