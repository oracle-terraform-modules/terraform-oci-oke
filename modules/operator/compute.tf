# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  boot_volume_size = lookup(var.shape, "boot_volume_size", 50)
  memory           = lookup(var.shape, "memory", 4)
  ocpus            = max(1, lookup(var.shape, "ocpus", 1))
  shape            = lookup(var.shape, "shape", "VM.Standard.E4.Flex")
}

output "id" {
  value = oci_core_instance.operator.id
}

output "private_ip" {
  value = oci_core_instance.operator.private_ip
}

resource "oci_core_instance" "operator" {
  availability_domain                 = var.availability_domain
  compartment_id                      = var.compartment_id
  display_name                        = "operator-${var.state_id}"
  defined_tags                        = var.defined_tags
  freeform_tags                       = var.freeform_tags
  is_pv_encryption_in_transit_enabled = var.pv_transit_encryption
  shape                               = local.shape

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Service Agent"
    }
  }

  create_vnic_details {
    assign_public_ip = false
    display_name     = "operator-${var.state_id}"
    hostname_label   = var.assign_dns ? "o-${var.state_id}" : null
    nsg_ids          = var.nsg_ids
    subnet_id        = var.subnet_id
  }

  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.operator.rendered
  }

  dynamic "shape_config" {
    for_each = length(regexall("Flex", local.shape)) > 0 ? [1] : []
    content {
      ocpus         = local.ocpus
      memory_in_gbs = (local.memory / local.ocpus) > 64 ? (local.ocpus * 4) : local.memory
    }
  }

  source_details {
    boot_volume_size_in_gbs = local.boot_volume_size
    source_type             = "image"
    source_id               = var.image_id
    kms_key_id              = var.volume_kms_key_id
  }

  lifecycle {
    ignore_changes = [
      availability_domain,
      defined_tags, freeform_tags, display_name,
      create_vnic_details, metadata, source_details,
    ]

    replace_triggered_by = [null_resource.operator_changed]
    precondition {
      condition     = coalesce(var.image_id, "none") != "none"
      error_message = "Missing image_id for operator. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'platform'."
    }
  }

  timeouts {
    create = "60m"
  }
}

resource "null_resource" "operator_changed" {
  triggers = {
    cloud_init      = jsonencode(var.cloud_init)
    image_id        = var.image_id
    install_helm    = var.install_helm
    install_k9s     = var.install_k9s
    install_kubectx = var.install_kubectx
    ssh_public_key  = var.ssh_public_key
  }
}
