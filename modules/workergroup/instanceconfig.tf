# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_instance_configuration" "instance_configuration" {
  # Create an OCI Instance Configuration resource for each enabled entry of the worker_groups map with a mode that uses one.
  for_each       = local.enabled_instance_configs
  compartment_id = lookup(each.value, "compartment_id", local.compartment_id)
  display_name   = join("-", compact([lookup(each.value, "label_prefix", var.label_prefix), each.key]))

  instance_details {
    instance_type = "compute"

    launch_details {
      # Define each configured availability domain for placement, with bounds on # available
      # Configured AD numbers e.g. [1,2,3] are converted into tenancy/compartment-specific names
      availability_domain = lookup(local.ad_number_to_name, (
        contains(keys(each.value), "placement_ads")
        ? element(tolist(setintersection(each.value.placement_ads, local.ad_numbers)), 1)
        : element(local.ad_numbers, 1)
      ), "")
      compartment_id = lookup(each.value, "compartment_id", local.compartment_id)
      defined_tags   = merge(coalesce(local.defined_tags, {}), contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
      freeform_tags  = merge(coalesce(local.freeform_tags, {}), contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })

      instance_options {
        are_legacy_imds_endpoints_disabled = false
      }

      create_vnic_details {
        assign_public_ip = false
        nsg_ids          = contains(keys(each.value), "nsg_ids") ? each.value.nsg_ids : var.worker_nsg_ids
        subnet_id        = var.primary_subnet_id
      }

      metadata = {
        oke-k8version            = "v1.22.5" # Temp kube-proxy fix; version doesn't matter other than >1.21 for IPVS
        oke-kubeproxy-proxy-mode = var.kubeproxy_mode
        ssh_authorized_keys      = local.ssh_public_key
        user_data                = data.cloudinit_config.worker_ip.rendered
      }

      shape = lookup(each.value, "shape", local.shape)

      dynamic "shape_config" {
        for_each = length(regexall("Flex", lookup(each.value, "shape", local.shape))) > 0 ? [1] : []
        content {
          ocpus = max(1, lookup(each.value, "ocpus", local.ocpus))
          memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
            (lookup(each.value, "memory", local.memory) / lookup(each.value, "ocpus", local.ocpus)) > 64
            ? (lookup(each.value, "ocpus", local.ocpus) * 64)
            : lookup(each.value, "memory", local.memory)
          )
        }
      }

      source_details {
        boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size", local.boot_volume_size)
        image_id                = lookup(each.value, "image_id", var.image_id)
        source_type             = "image"
      }
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      defined_tags, freeform_tags, display_name,
      instance_details[0].launch_details[0].metadata,
      instance_details[0].launch_details[0].defined_tags,
      instance_details[0].launch_details[0].freeform_tags,
    ]
  }
}