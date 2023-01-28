# Copyright (c) 2019, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  boot_volume_size = lookup(var.shape, "boot_volume_size", 50)
  memory           = lookup(var.shape, "memory", 4)
  ocpus            = max(1, lookup(var.shape, "ocpus", 1))
  shape            = lookup(var.shape, "shape", "VM.Standard.E4.Flex")

  defined_tags = merge(var.defined_tags, var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = var.state_id,
    "${var.tag_namespace}.role"     = "bastion",
  } : {})

  freeform_tags = merge(var.freeform_tags, !var.use_defined_tags ? {
    "state_id" = var.state_id,
    "role"     = "bastion",
  } : {})
}

data "cloudinit_config" "bastion" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "bastion.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/cloudinit/bastion.template.yaml", {
      timezone = var.timezone
      upgrade  = var.upgrade
      user     = var.user
    })
  }
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
  defined_tags        = local.defined_tags
  display_name        = "bastion-${var.state_id}"
  freeform_tags       = local.freeform_tags
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
    assign_public_ip = var.public
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
      ocpus         = local.ocpus
      memory_in_gbs = (local.memory / local.ocpus) > 64 ? (local.ocpus * 4) : local.memory
    }
  }

  source_details {
    boot_volume_size_in_gbs = local.boot_volume_size
    source_id               = var.image_id
    source_type             = "image"
  }

  lifecycle {
    ignore_changes = [availability_domain, defined_tags, freeform_tags, metadata, source_details]

    precondition {
      condition     = coalesce(var.image_id, "none") != "none"
      error_message = "Missing image_id for bastion. Check provided value for image_id if image_type is 'custom', or image_os/image_os_version if image_type is 'platform'."
    }
  }

  timeouts {
    create = "60m"
  }
}
