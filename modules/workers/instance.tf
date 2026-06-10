resource "oci_core_instance" "workers" {
  for_each             = local.enabled_instances
  availability_domain  = element(each.value.availability_domains, 1)
  fault_domain         = try(each.value.placement_fds[0], null)
  compartment_id       = each.value.compartment_id
  display_name         = each.key
  preserve_boot_volume = false
  shape                = each.value.shape

  defined_tags            = each.value.defined_tags
  freeform_tags           = each.value.freeform_tags
  extended_metadata       = each.value.extended_metadata
  capacity_reservation_id = each.value.capacity_reservation_id

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

  create_vnic_details {
    assign_private_dns_record = var.assign_dns
    assign_ipv6ip             = each.value.assign_ipv6ip
    assign_public_ip          = each.value.assign_public_ip
    nsg_ids                   = each.value.nsg_ids
    subnet_id                 = each.value.subnet_id
    defined_tags              = each.value.defined_tags
    freeform_tags             = each.value.freeform_tags
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = each.value.legacy_imds_endpoints_disabled
  }

  metadata = merge(
    {
      apiserver_host           = var.apiserver_private_host
      cluster_ca_cert          = var.cluster_ca_cert
      oke-k8version            = var.kubernetes_version
      oke-kubeproxy-proxy-mode = var.kubeproxy_mode
      oke-tenancy-id           = var.tenancy_id
      oke-initial-node-labels  = join(",", [for k, v in each.value.node_labels : format("%v=%v", k, v)])
      ssh_authorized_keys      = var.ssh_public_key
      user_data                = lookup(lookup(data.cloudinit_config.workers, lookup(each.value, "key", ""), {}), "rendered", "")
    },

    # Add labels required for NPN CNI.
    var.cni_type == "npn" ? merge(
      length(each.value.gva_secondary_vnics) == 0 ?
      {
        oke-native-pod-networking = true
        oke-max-pods              = each.value.max_pods_per_node
        pod-subnets               = each.value.pod_subnet_id
        pod-nsgids                = join(",", each.value.pod_nsg_ids)
      } :
      {
        oke-native-pod-networking = true
        oke-max-pods              = sum([for key, va in each.value.gva_secondary_vnics : va.ip_count])
        secondary-vnics = jsonencode([for key, va in each.value.gva_secondary_vnics : {
          createVnicDetails = merge(
            {
              displayName         = lookup(va, "display_name", key)
              subnetId            = va.subnet_id
              ipCount             = va.ip_count
              nsgIds              = va.nsg_ids
              skipSourceDestCheck = va.skip_source_dest_check
            },
            va.application_resources != null ? { applicationResources = va.application_resources } : {},
            va.assign_public_ip == true ? { assignPublicIp = va.assign_public_ip } : {},
            va.assign_ipv6ip == true ? { assignIpv6Ip = va.assign_ipv6ip } : {},
          )
          nicIndex    = va.nic_index
          displayName = lookup(va, "display_name", key)
          }
        ])
      },
      local.oke_uses_ipv6 ?
      {
        ip-families = join(",", var.oke_ip_families)
      } : {}
    ) :
    {},

    # Only provide cluster DNS service address if set explicitly; determined automatically in practice.
    coalesce(var.cluster_dns, "none") == "none" ? {} : { kubedns_svc_ip = var.cluster_dns },

    # Extra user-defined fields merged last
    var.node_metadata,                       # global
    lookup(each.value, "node_metadata", {}), # pool-specific
  )

  source_details {
    boot_volume_size_in_gbs = each.value.boot_volume_size
    boot_volume_vpus_per_gb = each.value.boot_volume_vpus_per_gb
    source_id               = each.value.image_id
    source_type             = "image"
  }

  lifecycle {
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
        length(lookup(each.value, "gva_secondary_vnics", {})) == 0,
        var.cni_type == "npn",
      ])
      error_message = "gva_secondary_vnics for self-managed workers requires cni_type = npn."
    }

    precondition {
      condition = alltrue([
        for _, vnic in lookup(each.value, "gva_secondary_vnics", {}) :
        try(trimspace(vnic.subnet_id), "") != ""
      ])
      error_message = "gva_secondary_vnics entries must resolve to a non-empty subnet_id. Use cni_type = npn for the default pod subnet, or provide an explicit subnet_id."
    }

    precondition {
      condition = alltrue([
        for _, vnic in lookup(each.value, "gva_secondary_vnics", {}) :
        contains([1, 2, 4, 8, 16, 32, 64, 128, 256], lookup(vnic, "ip_count", 32))
      ])
      error_message = "gva_secondary_vnics ip_count must be a power of two from 1 to 256."
    }

    ignore_changes = [
      agent_config, # TODO Not updateable; remove when supported
      defined_tags, freeform_tags, display_name,
      metadata["cluster_ca_cert"], metadata["user_data"],
      create_vnic_details[0].defined_tags,
      create_vnic_details[0].freeform_tags,
    ]
  }
}
