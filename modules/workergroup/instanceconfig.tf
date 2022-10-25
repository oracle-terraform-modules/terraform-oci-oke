# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_instance_configuration" "instance_configuration" {
  # Create an OCI Instance Configuration resource for each enabled entry of the worker_groups map with a mode that uses one.
  for_each       = local.enabled_instance_configs
  compartment_id = each.value.compartment_id
  display_name   = "${each.value.label_prefix}-${each.key}"

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
      compartment_id = each.value.compartment_id
      defined_tags = merge(
        local.defined_tags,
        lookup(each.value, "defined_tags", {}),
      )
      freeform_tags = merge(local.freeform_tags, contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })

      instance_options {
        are_legacy_imds_endpoints_disabled = false
      }

      create_vnic_details {
        assign_private_dns_record = var.assign_dns
        assign_public_ip          = each.value.assign_public_ip
        nsg_ids                   = each.value.worker_nsgs
        subnet_id                 = each.value.subnet_id
      }

      metadata = {
        apiserver_host           = var.apiserver_private_host
        cluster_ca_cert          = local.cluster_ca_cert
        kubedns_svc_ip           = var.cluster_dns
        oke-k8version            = var.kubernetes_version
        oke-kubeproxy-proxy-mode = var.kubeproxy_mode
        oke-tenancy-id           = local.tenancy_id
        oke-initial-node-labels = join(",", [
          for k, v in merge(var.node_labels, each.value.node_labels) : join("=", [k, v])
        ])
        ssh_authorized_keys = local.ssh_public_key
        user_data           = data.cloudinit_config.worker_per_boot.rendered
      }

      shape = each.value.shape

      dynamic "shape_config" {
        for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
        content {
          ocpus = each.value.ocpus
          memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
            (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
          )
        }
      }

      source_details {
        boot_volume_size_in_gbs = each.value.boot_volume_size
        image_id                = each.value.image_id
        source_type             = "image"
      }

      is_pv_encryption_in_transit_enabled = var.enable_pv_encryption_in_transit
    }

    block_volumes {
      attach_details {
        type                                = var.block_volume_type
        is_pv_encryption_in_transit_enabled = var.block_volume_type == "paravirtualized" && var.enable_pv_encryption_in_transit
      }

      create_details {
        display_name   = "${each.value.label_prefix}-${each.key}"
        kms_key_id     = var.volume_kms_key_id
        compartment_id = each.value.compartment_id
      }
    }
  }

  lifecycle {

    # TODO Instance Configuration replacement without delete when supported:
    # https://github.com/hashicorp/terraform/issues/15485
    create_before_destroy = true
    ignore_changes = [
      defined_tags, freeform_tags, display_name,
      instance_details[0].launch_details[0].metadata,
      instance_details[0].launch_details[0].defined_tags,
      instance_details[0].launch_details[0].freeform_tags,
    ]
  }
}