resource "oci_core_instance" "workers" {
  for_each             = local.enabled_instances
  availability_domain  = element(each.value.availability_domains, 1)
  compartment_id       = each.value.compartment_id
  display_name         = each.key
  preserve_boot_volume = false
  shape                = each.value.shape

  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags

  dynamic "shape_config" {
    for_each = length(regexall("Flex", each.value.shape)) > 0 ? [1] : []
    content {
      ocpus = each.value.ocpus
      memory_in_gbs = ( # If > 64GB memory/core, correct input to exactly 64GB memory/core
        (each.value.memory / each.value.ocpus) > 64 ? each.value.ocpus * 64 : each.value.memory
      )
    }
  }

  dynamic "platform_config" {
    for_each = each.value.platform_config != null ? [1] : []
    content {
      type                                           = lookup(each.value.platform_config, "type")
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
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
  }

  create_vnic_details {
    assign_private_dns_record = var.assign_dns
    assign_public_ip          = each.value.assign_public_ip
    nsg_ids                   = each.value.nsg_ids
    subnet_id                 = each.value.subnet_id
    defined_tags              = each.value.defined_tags
    freeform_tags             = each.value.freeform_tags
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }

  metadata = merge(
    {
      apiserver_host           = var.apiserver_private_host
      cluster_ca_cert          = var.cluster_ca_cert
      oke-k8version            = var.kubernetes_version
      oke-kubeproxy-proxy-mode = var.kubeproxy_mode
      oke-tenancy-id           = var.tenancy_id
      oke-initial-node-labels  = join(",", [for k, v in each.value.node_labels : "${k}=${v}"])
      secondary_vnics          = jsonencode(lookup(each.value, "secondary_vnics", {}))
      ssh_authorized_keys      = var.ssh_public_key
      user_data                = lookup(lookup(data.cloudinit_config.workers, lookup(each.value, "key", ""), {}), "rendered", "")
    },

    # Only provide cluster DNS service address if set explicitly; determined automatically in practice.
    coalesce(var.cluster_dns, "none") == "none" ? {} : { kubedns_svc_ip = var.cluster_dns },

    # Extra user-defined fields merged last
    var.node_metadata,                       # global
    lookup(each.value, "node_metadata", {}), # pool-specific
  )

  source_details {
    boot_volume_size_in_gbs = each.value.boot_volume_size
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

    ignore_changes = [
      defined_tags, freeform_tags, display_name,
      metadata["cluster_ca_cert"], metadata["user_data"],
      create_vnic_details[0].defined_tags,
      create_vnic_details[0].freeform_tags,
    ]
  }
}
