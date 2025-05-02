# Copyright (c) 2022, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Create the shared compute clusters defined in workers_compute_clusters

resource "oci_core_compute_cluster" "shared" {
  # Create an OCI Compute Cluster resource for each enabled entry of the worker_pools map with that mode.
  for_each       = var.compute_clusters
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  display_name   = each.key
  defined_tags = merge(
    var.defined_tags,
    lookup(each.value, "defined_tags", {})
  )
  freeform_tags = merge(
    var.freeform_tags,
    lookup(each.value, "freeform_tags", {})
  )

  availability_domain = lookup(var.ad_numbers_to_names, lookup(each.value, "placement_ad", 1))

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
    ]
  }
}

# Dynamic resource block for Compute Cluster groups defined in worker_pools
resource "oci_core_compute_cluster" "workers" {
  # Create an OCI Compute Cluster resource for each enabled entry of the worker_pools map with that mode.
  for_each            = { for k, v in local.enabled_compute_clusters : k => v if length(lookup(v, "instance_ids", [])) > 0 && lookup(v, "compute_cluster", null) == null }
  compartment_id      = each.value.compartment_id
  display_name        = each.key
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags
  availability_domain = lookup(each.value, "placement_ad", null) != null ? lookup(var.ad_numbers_to_names, lookup(each.value, "placement_ad")) : element(each.value.availability_domains, 0)

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
    ]
  }
}

resource "oci_core_instance" "compute_cluster_workers" {
  for_each = local.compute_cluster_instance_map

  availability_domain  = (lookup(oci_core_compute_cluster.shared, lookup(each.value, "compute_cluster", ""), null) != null ?
    oci_core_compute_cluster.shared[lookup(each.value, "compute_cluster", "")].availability_domain :
    lookup(each.value, "placement_ad", null) != null ? lookup(var.ad_numbers_to_names, lookup(each.value, "placement_ad")) : element(each.value.availability_domains, 0)
  )
  fault_domain         = try(each.value.placement_fds[0], null)
  compartment_id       = each.value.compartment_id
  display_name         = format("%s-%s", element(split("###", each.key), 0), element(split("###", each.key), 1))
  preserve_boot_volume = false
  shape                = each.value.shape

  defined_tags            = each.value.defined_tags
  freeform_tags           = each.value.freeform_tags
  extended_metadata       = each.value.extended_metadata
  capacity_reservation_id = each.value.capacity_reservation_id
  compute_cluster_id = (lookup(oci_core_compute_cluster.shared, lookup(each.value, "compute_cluster", ""), null) != null ?
    oci_core_compute_cluster.shared[lookup(each.value, "compute_cluster", "")].id :
    (lookup(oci_core_compute_cluster.workers, element(split("###", each.key), 0), null) != null ?
      oci_core_compute_cluster.workers[element(split("###", each.key), 0)].id :
      lookup(each.value, "compute_cluster", "")
    )
  )

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
      for_each = merge(
        {
          "Compute HPC RDMA Authentication" : "ENABLED",
          "Compute HPC RDMA Auto-Configuration" : "ENABLED"
        },
        each.value.agent_config.plugins_config
      )
      content {
        name          = plugins_config.key
        desired_state = plugins_config.value
      }
    }
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
      oke-initial-node-labels  = join(",", [for k, v in each.value.node_labels : format("%v=%v", k, v)])
      secondary_vnics          = jsonencode(lookup(each.value, "secondary_vnics", {}))
      ssh_authorized_keys      = var.ssh_public_key
      user_data                = lookup(lookup(data.cloudinit_config.workers, element(split("###", each.key), 0), {}), "rendered", "")
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
        pool: ${element(split("###", each.key), 0)}
        image_type: ${coalesce(each.value.image_type, "none")}
        image_id: ${coalesce(each.value.image_id, "none")}
      EOT
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
