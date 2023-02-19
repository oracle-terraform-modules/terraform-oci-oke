# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Used to retrieve available worker node images, k8s versions, shapes...
data "oci_containerengine_node_pool_option" "oke" {
  node_pool_option_id = "all"
  compartment_id      = local.compartment_id
}

locals {
  k8s_version_length = length(var.kubernetes_version)
  k8s_version_only   = substr(var.kubernetes_version, 1, local.k8s_version_length)

  # OKE managed node pool images
  node_pool_images = try(data.oci_containerengine_node_pool_option.oke.sources, [])

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
      },
    )
  }

  # Create non-exclusive groupings of image IDs for intersection when selecting based on config and instance shape
  image_ids = merge({
    x86_64   = [for k, v in local.parsed_images : k if v.arch == "x86_64"]
    aarch64  = [for k, v in local.parsed_images : k if v.arch == "aarch64"]
    oke      = [for k, v in local.parsed_images : k if v.image_type == "oke" && v.k8s_version == local.k8s_version_only]
    platform = [for k, v in local.parsed_images : k if v.image_type == "platform"]
    gpu      = [for k, v in local.parsed_images : k if v.is_gpu]
    nongpu   = [for k, v in local.parsed_images : k if !v.is_gpu]
    }, {
    # Include groups for OS name and major version
    # https://developer.hashicorp.com/terraform/language/expressions/for#grouping-results
    for k, v in local.parsed_images : "${v.os} ${split(".", v.os_version)[0]}" => k...
  })
}
