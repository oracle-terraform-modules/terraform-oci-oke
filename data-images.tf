# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Used to retrieve available worker node images, k8s versions, shapes...
data "oci_containerengine_node_pool_option" "oke" {
  count               = local.cluster_enabled ? 1 : 0
  node_pool_option_id = "all"
  compartment_id      = local.compartment_id
}

locals {
  k8s_versions      = toset(concat([var.kubernetes_version], [for k, v in var.worker_pools : lookup(v, "kubernetes_version", "") if lookup(v, "kubernetes_version", "") != ""]))
  k8s_versions_only = [for k8_version in local.k8s_versions : trimprefix(lower(k8_version), "v")]

  # OKE managed node pool images
  node_pool_images = try(one(data.oci_containerengine_node_pool_option.oke[*].sources), [])

  # Parse platform/operating system information from node pool image names
  indexed_images = try({
    for k, v in local.node_pool_images : v.image_id => merge(
      try(element(regexall("OKE-(?P<k8s_version>[0-9\\.]+)-(?P<build>[0-9]+)", v.source_name), 0), { k8s_version = "none" }),
      {
        arch        = length(regexall("aarch64", v.source_name)) > 0 ? "aarch64" : "x86_64"
        image_type  = length(regexall("OKE", v.source_name)) > 0 ? "oke" : "platform"
        is_gpu      = length(regexall("GPU", v.source_name)) > 0
        os          = trimspace(replace(element(regexall("^[a-zA-Z-]+", v.source_name), 0), "-", " "))
        os_version  = element(regexall("[0-9\\.]+", v.source_name), 0)
        sort_key    = replace(try(join(".", regex("-([0-9]{4}\\.[01][0-9].[0-9]{1,2}).*?-([0-9]+)$", v.source_name)), v.source_name), ".", "")
        source_name = v.source_name
      },
    )
  }, {})

  # Create non-exclusive groupings of image IDs for intersection when selecting based on config and instance shape
  image_ids = try(merge({
    x86_64   = [for k, v in local.indexed_images : k if v.arch == "x86_64"]
    aarch64  = [for k, v in local.indexed_images : k if v.arch == "aarch64"]
    oke      = [for k, v in local.indexed_images : k if v.image_type == "oke" && contains(local.k8s_versions_only, v.k8s_version)]
    platform = [for k, v in local.indexed_images : k if v.image_type == "platform"]
    gpu      = [for k, v in local.indexed_images : k if v.is_gpu]
    nongpu   = [for k, v in local.indexed_images : k if !v.is_gpu]
    }, {
    # Include groups for OS name and major version
    # https://developer.hashicorp.com/terraform/language/expressions/for#grouping-results
    for k, v in local.indexed_images : format("%v %v", v.os, split(".", v.os_version)[0]) => k...
    }, {
    # Include groups for referenced Kubernetes versions
    for k, v in local.indexed_images : format("%v", v.k8s_version) => k... if contains(local.k8s_versions_only, v.k8s_version)
  }), {})
}
