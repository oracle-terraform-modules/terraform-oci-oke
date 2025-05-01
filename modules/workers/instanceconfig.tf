# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_instance_configuration" "workers" {
  # Create an OCI Instance Configuration resource for each enabled entry of the worker_pools map with a mode that uses one.
  for_each       = local.enabled_instance_configs
  compartment_id = each.value.compartment_id
  display_name   = each.key
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  instance_details {
    instance_type = "compute"

    launch_details {
      agent_config {
        are_all_plugins_disabled = each.value.agent_config.are_all_plugins_disabled
        is_management_disabled   = each.value.agent_config.is_management_disabled
        is_monitoring_disabled   = each.value.agent_config.is_monitoring_disabled
        dynamic "plugins_config" {
          for_each = each.value.agent_config.plugins_config
          content {
            name          = plugins_config.key
            desired_state = plugins_config.value
          }
        }
      }

      availability_domain = element(each.value.availability_domains, 1)

      # First value specified on pool, or null to select automatically
      fault_domain = try(each.value.placement_fds[0], null)

      compartment_id          = each.value.compartment_id
      defined_tags            = each.value.defined_tags
      freeform_tags           = each.value.freeform_tags
      extended_metadata       = each.value.extended_metadata
      capacity_reservation_id = each.value.capacity_reservation_id

      instance_options {
        are_legacy_imds_endpoints_disabled = false
      }

      create_vnic_details {
        assign_private_dns_record = var.assign_dns
        assign_public_ip          = each.value.assign_public_ip
        nsg_ids                   = each.value.nsg_ids
        subnet_id                 = each.value.subnet_id
        defined_tags              = each.value.defined_tags
        freeform_tags             = each.value.freeform_tags
      }

      metadata = merge(
        {
          apiserver_host           = var.apiserver_private_host
          cluster_ca_cert          = var.cluster_ca_cert
          oke-k8version            = var.kubernetes_version
          oke-kubeproxy-proxy-mode = var.kubeproxy_mode
          oke-tenancy-id           = var.tenancy_id
          oke-initial-node-labels  = join(",", [for k, v in each.value.node_labels : format("%v=%v", k, v)])
          secondary_vnics          = jsonencode(lookup(each.value, "secondary_vnics", {}))
          ssh_authorized_keys      = var.ssh_public_key
          user_data                = lookup(lookup(data.cloudinit_config.workers, each.key, {}), "rendered", "")
        },

        # Add labels required for NPN CNI.
        var.cni_type == "npn" ? {
          oke-native-pod-networking = true
          oke-max-pods              = var.max_pods_per_node
          pod-subnets               = coalesce(var.pod_subnet_id, var.worker_subnet_id, "none")
          pod-nsgids                = join(",", each.value.pod_nsg_ids)
        } : {},

        # Only provide cluster DNS service address if set explicitly; determined automatically in practice.
        coalesce(var.cluster_dns, "none") == "none" ? {} : { kubedns_svc_ip = var.cluster_dns },

        # Extra user-defined fields merged last
        var.node_metadata,                       # global
        lookup(each.value, "node_metadata", {}), # pool-specific
      )

      shape = each.value.shape

      dynamic "shape_config" {
        for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
        content {
          baseline_ocpu_utilization = lookup(each.value, "burst", "BASELINE_1_1")
          ocpus                     = each.value.ocpus
          memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
            (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
          )
        }
      }

      dynamic "platform_config" {
        for_each = each.value.platform_config != null ? [1] : []
        content {
          type = lookup(
            # Attempt lookup against data source for the associated 'type' of configured worker shape
            lookup(local.platform_config_by_shape, each.value.shape, {}), "type",
            # Fall back to 'type' on pool with custom platform_config, or INTEL_VM default
            lookup(each.value.platform_config, "type", "INTEL_VM")
          )
          # Remaining parameters as configured, validated by instance/instance config resource
          are_virtual_instructions_enabled               = lookup(each.value.platform_config, "are_virtual_instructions_enabled", null)
          is_access_control_service_enabled              = lookup(each.value.platform_config, "is_access_control_service_enabled", null)
          is_input_output_memory_management_unit_enabled = lookup(each.value.platform_config, "is_input_output_memory_management_unit_enabled", null)
          is_measured_boot_enabled                       = lookup(each.value.platform_config, "is_measured_boot_enabled", null)
          is_memory_encryption_enabled                   = lookup(each.value.platform_config, "is_memory_encryption_enabled", null)
          is_secure_boot_enabled                         = lookup(each.value.platform_config, "is_secure_boot_enabled", null)
          is_symmetric_multi_threading_enabled           = lookup(each.value.platform_config, "is_symmetric_multi_threading_enabled", null)
          is_trusted_platform_module_enabled             = lookup(each.value.platform_config, "is_trusted_platform_module_enabled", null)
          numa_nodes_per_socket                          = lookup(each.value.platform_config, "numa_nodes_per_socket", null)
          percentage_of_cores_enabled                    = lookup(each.value.platform_config, "percentage_of_cores_enabled", null)
        }
      }

      source_details {
        boot_volume_size_in_gbs = each.value.boot_volume_size
        boot_volume_vpus_per_gb = each.value.boot_volume_vpus_per_gb
        image_id                = each.value.image_id
        source_type             = "image"
      }

      is_pv_encryption_in_transit_enabled = each.value.pv_transit_encryption
    }

    dynamic "block_volumes" {
      for_each = (lookup(each.value, "disable_block_volume", false) != true) ? [1] : []
      content {
        attach_details {
          type                                = each.value.block_volume_type
          is_pv_encryption_in_transit_enabled = each.value.pv_transit_encryption
        }

        create_details {
          // Limit to first candidate placement AD for cluster-network; undefined for all otherwise
          availability_domain = each.value.mode == "cluster-network" ? element(each.value.availability_domains, 1) : null
          compartment_id      = each.value.compartment_id
          display_name        = each.key
          kms_key_id          = each.value.volume_kms_key_id
          size_in_gbs         = max(50, lookup(each.value, "block_volume_size_in_gbs", 50))
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
      instance_details[0].launch_details[0].defined_tags,
      instance_details[0].launch_details[0].freeform_tags,
      instance_details[0].launch_details[0].create_vnic_details[0].defined_tags,
      instance_details[0].launch_details[0].create_vnic_details[0].freeform_tags,
      instance_details[0].secondary_vnics,
    ]
  }
}
