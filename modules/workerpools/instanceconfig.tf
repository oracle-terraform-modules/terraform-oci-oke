# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_instance_configuration" "workers" {
  # Create an OCI Instance Configuration resource for each enabled entry of the worker_pools map with a mode that uses one.
  for_each       = local.enabled_instance_configs
  compartment_id = each.value.compartment_id
  display_name   = each.key

  instance_details {
    instance_type = "compute"



    launch_details {
      availability_domain = element(each.value.availability_domains, 1)
      compartment_id      = each.value.compartment_id

      defined_tags = merge(
        local.defined_tags,
        lookup(each.value, "defined_tags", {}),
      )
      freeform_tags = merge(local.freeform_tags, contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_pool = each.key })

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

      is_pv_encryption_in_transit_enabled = each.value.pv_encryption
    }

    dynamic "block_volumes" {
      for_each = each.value.availability_domains
      iterator = ad
      content {
        attach_details {
          type                                = each.value.block_volume_type
          is_pv_encryption_in_transit_enabled = each.value.pv_encryption
        }

        create_details {
          availability_domain = ad.value
          compartment_id      = each.value.compartment_id
          display_name        = each.key
          kms_key_id          = var.volume_kms_key_id
        }
      }
    }

    dynamic "secondary_vnics" {
      for_each = lookup(each.value, "secondary_vnics", {})
      iterator = vnic

      content {
        display_name = vnic.key
        nic_index    = lookup(vnic.value, "nic_index", null)

        create_vnic_details {
          assign_private_dns_record = lookup(vnic.value, "assign_private_dns_record", null)
          assign_public_ip          = lookup(vnic.value, "assign_public_ip", null)
          display_name              = vnic.key
          defined_tags              = lookup(vnic.value, "defined_tags", null)
          freeform_tags             = lookup(vnic.value, "freeform_tags", null)
          hostname_label            = lookup(vnic.value, "hostname_label", null)
          nsg_ids                   = lookup(vnic.value, "nsg_ids", null)
          private_ip                = lookup(vnic.value, "private_ip", null)
          skip_source_dest_check    = lookup(vnic.value, "skip_source_dest_check", null)
          subnet_id                 = lookup(vnic.value, "subnet_id", each.value.subnet_id)
        }
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