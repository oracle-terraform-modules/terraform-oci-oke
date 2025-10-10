# Copyright (c) 2019, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  boot_volume_size = tonumber(lookup(var.shape, "boot_volume_size", 50))
  memory           = tonumber(lookup(var.shape, "memory", 4))
  ocpus            = max(1, tonumber(lookup(var.shape, "ocpus", 1)))
  shape            = lookup(var.shape, "shape", "VM.Standard.E4.Flex")

  baseline_ocpu_utilization_map = {
    "12.5" = "BASELINE_1_8"
    "50"   = "BASELINE_1_2"
    "100"  = "BASELINE_1_1"
  }
  baseline_ocpu_utilization = lookup(local.baseline_ocpu_utilization_map, lookup(var.shape, "baseline_ocpu_utilization", "100"))
}

output "id" {
  value = oci_core_instance.bastion.id
}

output "public_ip" {
  value = oci_core_instance.bastion.public_ip
}

resource "oci_core_instance" "bastion" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "bastion-${var.state_id}"
  defined_tags        = var.defined_tags
  freeform_tags       = var.freeform_tags
  shape               = lookup(var.shape, "shape")

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }

  create_vnic_details {
    assign_public_ip = var.is_public
    display_name     = "bastion-${var.state_id}"
    hostname_label   = var.assign_dns ? "b-${var.state_id}" : null
    nsg_ids          = var.nsg_ids
    subnet_id        = var.subnet_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.bastion.rendered
  }

  dynamic "shape_config" {
    for_each = length(regexall("Flex", local.shape)) > 0 ? [1] : []
    content {
      baseline_ocpu_utilization = local.baseline_ocpu_utilization
      ocpus                     = local.ocpus
      memory_in_gbs             = (local.memory / local.ocpus) > 64 ? (local.ocpus * 4) : local.memory
    }
  }

  source_details {
    boot_volume_size_in_gbs = local.boot_volume_size
    source_id               = var.image_id
    source_type             = "image"
    kms_key_id              = var.volume_kms_key_id
  }

  lifecycle {
    ignore_changes = [
      availability_domain,
      defined_tags, freeform_tags, display_name,
      create_vnic_details, metadata, source_details,
    ]

    precondition {
      condition     = coalesce(var.image_id, "none") != "none"
      error_message = "Missing image_id for bastion. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'platform'."
    }
  }

  timeouts {
    create = "60m"
  }
}
