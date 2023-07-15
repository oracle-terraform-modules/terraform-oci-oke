# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  boot_volume_size = lookup(var.shape, "boot_volume_size", 50)
  memory           = lookup(var.shape, "memory", 4)
  ocpus            = max(1, lookup(var.shape, "ocpus", 1))
  shape            = lookup(var.shape, "shape", "VM.Standard.E4.Flex")

  worker_pool_defaults = {
    allow_autoscaler           = false
    assign_public_ip           = var.assign_public_ip
    autoscale                  = false
    block_volume_type          = var.block_volume_type
    boot_volume_size           = local.boot_volume_size
    capacity_reservation_id    = var.capacity_reservation_id
    cloud_init                 = [] # empty pool-specific default
    compartment_id             = var.compartment_id
    create                     = true
    disable_default_cloud_init = var.disable_default_cloud_init
    drain                      = false
    extended_metadata          = {} # empty pool-specific default
    image_id                   = var.image_id
    image_type                 = var.image_type
    memory                     = local.memory
    mode                       = var.worker_pool_mode
    node_labels                = var.node_labels
    nsg_ids                    = [] # empty pool-specific default
    ocpus                      = local.ocpus
    os                         = var.image_os
    os_version                 = var.image_os_version
    placement_ads              = var.ad_numbers
    platform_config            = var.platform_config
    pod_nsg_ids                = var.pod_nsg_ids
    pod_subnet_id              = coalesce(var.pod_subnet_id, var.worker_subnet_id, "none")
    preemptible_config         = var.preemptible_config
    pv_transit_encryption      = var.pv_transit_encryption
    shape                      = local.shape
    size                       = var.worker_pool_size
    subnet_id                  = var.worker_subnet_id
    volume_kms_key_id          = var.volume_kms_key_id
  }

  # Merge desired pool configuration onto default values
  worker_pools_with_defaults = { for pool_name, pool in var.worker_pools :
    pool_name => merge(local.worker_pool_defaults, pool)
  }

  # Filter worker_pools map for enabled entries and add derived configuration
  enabled_worker_pools = { for pool_name, pool in local.worker_pools_with_defaults :
    pool_name => merge(pool, {
      preemptible_config = lookup(pool, "preemptible_config", pool.preemptible_config)
      # Bare metal instances must use iSCSI block volume attachments, not paravirtualized
      block_volume_type = length(regexall("^BM", pool.shape)) > 0 ? "iscsi" : var.block_volume_type
      pv_transit_encryption = alltrue([
        var.pv_transit_encryption,
        pool.block_volume_type == "paravirtualized",
        length(regexall("^VM", pool.shape)) > 0
      ])

      # Combine global and pool-specific cloud init parts
      cloud_init = [for part in concat(var.cloud_init, pool.cloud_init) :
        {
          # Load content from file if local path, attempt base64 decode, or use raw value
          content = contains(keys(part), "content") ? (
            fileexists(lookup(part, "content")) ? file(lookup(part, "content"))
            : try(base64decode(lookup(part, "content")), lookup(part, "content"))
          ) : ""
          content_type = lookup(part, "content_type", local.default_cloud_init_content_type)
          filename     = lookup(part, "filename", null)
          merge_type   = lookup(part, "merge_type", local.default_cloud_init_merge_type)
        }
      ]

      # Translate configured + available AD numbers e.g. 2 into tenancy/compartment-specific names
      availability_domains = compact([for ad_number in tolist(setintersection(pool.placement_ads, var.ad_numbers)) :
        lookup(var.ad_numbers_to_names, ad_number, null)
      ])

      # Use provided image_id for 'custom' type, or first match for all shape + OS criteria
      image_id = (pool.image_type == "custom" ? pool.image_id : element(tolist(setintersection([
        lookup(var.image_ids, pool.image_type, null),
        length(regexall("GPU", pool.shape)) > 0 ? var.image_ids.gpu : var.image_ids.nongpu,
        length(regexall("A1", pool.shape)) > 0 ? var.image_ids.aarch64 : var.image_ids.x86_64,
        lookup(var.image_ids, format("%v %v", pool.os, split(".", pool.os_version)[0]), null),
      ]...)), 0))

      # Standard tags as defined if enabled for use
      # User-provided freeform tags are merged and take precedence
      defined_tags = merge(
        var.use_defined_tags ? merge(
          {
            "${var.tag_namespace}.state_id"           = var.state_id,
            "${var.tag_namespace}.role"               = "worker",
            "${var.tag_namespace}.pool"               = pool_name,
            "${var.tag_namespace}.cluster_autoscaler" = pool.allow_autoscaler ? "allowed" : "disabled",
          },
          pool.autoscale ? { "${var.tag_namespace}.oraclecloud.com/cluster_autoscaler" = "managed" } : {},
        ) : {},
        var.defined_tags,
        lookup(pool, "defined_tags", {})
      )

      # Standard tags as freeform if defined tags are disabled
      # User-provided freeform tags are merged and take precedence
      freeform_tags = merge(
        var.use_defined_tags ? {} : merge(
          {
            "state_id"           = var.state_id,
            "role"               = "worker",
            "pool"               = pool_name,
            "cluster_autoscaler" = pool.allow_autoscaler ? "allowed" : "disabled",
          },
          pool.autoscale ? { "cluster_autoscaler" = "managed" } : {},
        ),
        var.freeform_tags,
        lookup(pool, "freeform_tags", {})
      )

      # Combine global and pool-specific NSGs
      nsg_ids = compact(concat(var.worker_nsg_ids, pool.nsg_ids))

      # Add a node label for cluster autoscaler where scheduling is supported
      node_labels = merge(
        {
          "oke.oraclecloud.com/tf.module"          = "terraform-oci-oke"
          "oke.oraclecloud.com/tf.state_id"        = var.state_id
          "oke.oraclecloud.com/tf.workspace"       = terraform.workspace
          "oke.oraclecloud.com/pool.name"          = pool_name
          "oke.oraclecloud.com/pool.mode"          = pool.mode
          "oke.oraclecloud.com/cluster_autoscaler" = pool.allow_autoscaler ? "allowed" : "disabled"
        },
        pool.autoscale ? { "oke.oraclecloud.com/cluster_autoscaler" = "managed" } : {},
        pool.node_labels,
      )
    }) if tobool(pool.create)
  }

  # Number of nodes expected from enabled worker pools
  expected_node_count = length(local.enabled_worker_pools) == 0 ? 0 : sum([
    for k, v in local.enabled_worker_pools : lookup(v, "size", var.worker_pool_size)
  ])

  # Number of nodes expected to be draining in worker pools
  expected_drain_count = length(local.enabled_worker_pools) == 0 ? 0 : sum([
    for k, v in local.enabled_worker_pools : tobool(v.drain) ? lookup(v, "size", var.worker_pool_size) : 0
  ])

  # Enabled worker_pool map entries for node pools
  enabled_node_pools = {
    for k, v in local.enabled_worker_pools : k => v if lookup(v, "mode", "") == "node-pool"
  }

  # Enabled worker_pool map entries for instance pools
  enabled_instance_configs = {
    for k, v in local.enabled_worker_pools : k => v
    if contains(["cluster-network", "instance-pool"], lookup(v, "mode", ""))
  }

  # Enabled worker_pool map entries for instance pools
  enabled_instance_pools = {
    for k, v in local.enabled_worker_pools : k => v if lookup(v, "mode", "") == "instance-pool"
  }

  # Enabled worker_pool map entries for individual instances
  enabled_instances = { for e in concat([], [
    for k, v in local.enabled_worker_pools : [
      for i in range(0, lookup(v, "size", 0)) : merge(v, { "key" = k, "index" = i })
    ] if lookup(v, "mode", "") == "instance"
  ]...) : format("%v-%v", lookup(e, "key"), lookup(e, "index")) => e }

  # Enabled worker_pool map entries for cluster networks
  enabled_cluster_networks = {
    for k, v in local.enabled_worker_pools : k => v if lookup(v, "mode", "") == "cluster-network"
  }

  # Sanitized worker_pools output; some conditionally-used defaults would be misleading
  worker_pools_final = {
    for pool_name, pool in local.enabled_worker_pools : pool_name => { for a, b in pool : a => b
      if a != "create"                                                                    # implied
      && b != null && try(length(b), -1) != 0 && try(!!tobool(b), true)                   # exclude empty/disabled values
      && !(contains(["os", "os_version"], a) && pool.image_type == "custom")              # unused defaults for custom
      && !(contains(["pod_nsg_ids", "pod_subnet_id"], a) && var.cni_type != "npn")        # unused defaults for NPN
      && !(contains(["ocpus", "memory"], a) && length(regexall("Flex", pool.shape)) == 0) # unused defaults for non-Flex shapes
    }
  }

  # Worker pool OCI resources enriched with desired/custom parameters
  worker_node_pools       = { for k, v in oci_containerengine_node_pool.workers : k => merge(v, lookup(local.worker_pools_final, k, {})) }
  worker_instance_pools   = { for k, v in oci_core_instance_pool.workers : k => merge(v, lookup(local.worker_pools_final, k, {})) }
  worker_cluster_networks = { for k, v in oci_core_cluster_network.workers : k => merge(v, lookup(local.worker_pools_final, k, {})) }
  worker_instances        = { for k, v in oci_core_instance.workers : k => merge(v, lookup(local.worker_pools_final, k, {})) }
  worker_pools_output     = merge(local.worker_node_pools, local.worker_instance_pools, local.worker_cluster_networks, local.worker_instances)
  worker_pool_ids         = { for k, v in local.worker_pools_output : k => v.id }
  worker_instance_ids     = { for k, v in local.enabled_instances : k => lookup(lookup(oci_core_instance.workers, k, {}), "id", "") }
}
