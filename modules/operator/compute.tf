# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  boot_volume_size = lookup(var.shape, "boot_volume_size", 50)
  memory           = lookup(var.shape, "memory", 4)
  ocpus            = max(1, lookup(var.shape, "ocpus", 1))
  shape            = lookup(var.shape, "shape", "VM.Standard.E4.Flex")

  defined_tags = merge(var.defined_tags, var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = var.state_id,
    "${var.tag_namespace}.role"     = "operator",
  } : {})

  freeform_tags = merge(var.freeform_tags, !var.use_defined_tags ? {
    "state_id" = var.state_id,
    "role"     = "operator",
  } : {})
}

output "id" {
  value = oci_core_instance.operator.id
}

output "private_ip" {
  value = oci_core_instance.operator.private_ip
}

data "cloudinit_config" "operator" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/cloudinit/operator.template.yaml", {
        kubernetes_version = var.kubernetes_version
        timezone           = var.timezone,
        upgrade            = var.upgrade,
        user               = var.user,
      }
    )
  }
}

resource "oci_core_instance" "operator" {
  availability_domain                 = var.availability_domain
  compartment_id                      = var.compartment_id
  defined_tags                        = local.defined_tags
  display_name                        = "operator-${var.state_id}"
  freeform_tags                       = local.freeform_tags
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
    ignore_changes = [availability_domain, defined_tags, freeform_tags, metadata, source_details]

    precondition {
      condition     = coalesce(var.image_id, "none") != "none"
      error_message = "Missing image_id for operator. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'platform'."
    }
  }

  timeouts {
    create = "60m"
  }
}
