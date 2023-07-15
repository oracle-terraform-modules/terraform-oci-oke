# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Node Pool groups defined in worker_pools
resource "oci_containerengine_node_pool" "workers" {
  # Create an OKE node pool resource for each enabled entry of the worker_pools map with that mode.
  for_each           = local.enabled_node_pools
  cluster_id         = var.cluster_id
  compartment_id     = each.value.compartment_id
  defined_tags       = each.value.defined_tags
  freeform_tags      = each.value.freeform_tags
  kubernetes_version = var.kubernetes_version
  name               = each.key
  node_shape         = each.value.shape
  ssh_public_key     = var.ssh_public_key

  node_config_details {
    size                                = each.value.size
    is_pv_encryption_in_transit_enabled = each.value.pv_transit_encryption
    kms_key_id                          = each.value.volume_kms_key_id
    nsg_ids                             = each.value.nsg_ids
    defined_tags                        = each.value.defined_tags
    freeform_tags                       = each.value.freeform_tags

    dynamic "placement_configs" {
      for_each = each.value.availability_domains
      iterator = ad

      content {
        availability_domain     = ad.value
        capacity_reservation_id = each.value.capacity_reservation_id
        subnet_id               = each.value.subnet_id

        # Intersect the list of available and configured FDs for this AD
        fault_domains = tolist(setintersection(
          each.value.placement_fds,
          lookup(local.fault_domains_available, ad.value, local.fault_domains_default)
        ))

        dynamic "preemptible_node_config" {
          for_each = each.value.preemptible_config.enable ? [1] : []
          content {
            preemption_action {
              type                    = "TERMINATE"
              is_preserve_boot_volume = each.value.preemptible_config.is_preserve_boot_volume
            }
          }
        }
      }
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "flannel" ? [1] : []
      content { # Flannel requires cni type only
        cni_type = "FLANNEL_OVERLAY"
      }
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "npn" ? [1] : []
      content { # VCN-Native requires max pods/node, nsg ids, subnet ids
        cni_type          = "OCI_VCN_IP_NATIVE"
        max_pods_per_node = min(max(var.max_pods_per_node, 1), 110)
        pod_nsg_ids       = compact(tolist(each.value.pod_nsg_ids))
        pod_subnet_ids    = compact(tolist([each.value.pod_subnet_id]))
      }
    }
  }

  node_metadata = merge(
    {
      apiserver_host           = var.apiserver_private_host
      oke-kubeproxy-proxy-mode = var.kubeproxy_mode
      user_data                = lookup(lookup(data.cloudinit_config.workers, each.key, {}), "rendered", "")
    },

    # Only provide cluster DNS service address if set explicitly; determined automatically in practice.
    coalesce(var.cluster_dns, "none") == "none" ? {} : { kubedns_svc_ip = var.cluster_dns },

    # Extra user-defined fields merged last
    var.node_metadata,                       # global
    lookup(each.value, "node_metadata", {}), # pool-specific
  )

  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
    content {
      ocpus = each.value.ocpus
      memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
        (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
      )
    }
  }

  node_source_details {
    boot_volume_size_in_gbs = each.value.boot_volume_size
    image_id                = each.value.image_id
    source_type             = "image"
  }

  lifecycle { # prevent resources changes for changed fields
    ignore_changes = [
      kubernetes_version, # e.g. if changed as part of an upgrade
      name, defined_tags, freeform_tags,
      node_metadata["user_data"],               # templated cloud-init
      node_config_details[0].placement_configs, # dynamic placement configs
      node_source_details[0],                   # dynamic image lookup
    ]

    precondition {
      condition     = coalesce(each.value.image_id, "none") != "none"
      error_message = <<-EOT
      Missing image_id; check provided value if image_type is 'custom', or image_os/image_os_version if image_type is 'oke' or 'platform'.
        pool: ${each.key}
        image_type: ${coalesce(each.value.image_type, "none")}
        image_id: ${coalesce(each.value.image_id, "none")}
      EOT
    }

    precondition {
      condition = anytrue([
        contains(["instance-pool", "cluster-network"], each.value.mode), # supported modes
        length(lookup(each.value, "secondary_vnics", {})) == 0,          # unrestricted when empty/unset
      ])
      error_message = "Unsupported option for mode=${each.value.mode}: secondary_vnics"
    }

    precondition {
      condition     = coalesce(each.value.capacity_reservation_id, "none") == "none" || length(each.value.availability_domains) == 1
      error_message = "A single availability domain must be specified when using a capacity reservation with mode=${each.value.mode}"
    }
  }

  dynamic "initial_node_labels" {
    for_each = each.value.node_labels
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
}
