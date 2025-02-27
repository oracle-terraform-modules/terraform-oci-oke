# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// Used to retrieve available bastion images when enabled
data "oci_core_images" "bastion" {
  count                    = var.create_bastion ? 1 : 0
  compartment_id           = local.compartment_id
  operating_system         = var.bastion_image_os
  operating_system_version = var.bastion_image_os_version
  shape                    = lookup(var.bastion_shape, "shape", "VM.Standard.E4.Flex")
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "launch_mode"
    values = ["NATIVE"]
  }
}

locals {
  bastion_public_ip = (var.create_bastion && length(module.bastion) > 0
    ? lookup(element(module.bastion, 0), "public_ip", var.bastion_public_ip)
    : var.bastion_public_ip
  )

  bastion_images    = try(data.oci_core_images.bastion[0].images, tolist([])) # Data source result or empty
  bastion_image_ids = local.bastion_images[*].id                              # Image OCIDs from data source
  bastion_image_id = (var.bastion_image_type == "custom"
    ? var.bastion_image_id : element(coalescelist(local.bastion_image_ids, ["none"]), 0)
  )

  # Bastion SSH ProxyCommand argument used in e.g. ssh_to_operator command output if created/provided
  bastion_ssh_user_ip = join("@", compact([var.bastion_user, local.bastion_public_ip]))
  bastion_ssh_args    = compact([local.ssh_key_arg, local.bastion_ssh_user_ip])
  bastion_ssh_command = join(" ", concat(["ssh"], local.bastion_ssh_args))
  bastion_proxy_command = try((local.bastion_public_ip == null ? []
    : ["-o", format("ProxyCommand='ssh -W %%h:%%p %v'", join(" ", local.bastion_ssh_args))]
  ), [])
}

module "bastion" {
  count          = var.create_bastion ? 1 : 0
  source         = "./modules/bastion"
  state_id       = local.state_id
  compartment_id = local.compartment_id

  # Bastion
  await_cloudinit          = var.bastion_await_cloudinit
  assign_dns               = var.assign_dns
  availability_domain      = coalesce(var.bastion_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  bastion_image_os_version = var.bastion_image_os_version
  image_id                 = local.bastion_image_id
  nsg_ids                  = try(compact(flatten([var.bastion_nsg_ids, [try(module.network.bastion_nsg_id, null)]])), [])
  is_public                = var.bastion_is_public
  shape                    = var.bastion_shape
  ssh_private_key          = sensitive(local.ssh_private_key) # to await cloud-init completion
  ssh_public_key           = local.ssh_public_key
  subnet_id                = try(module.network.bastion_subnet_id, "") # safe destroy; validated in submodule
  timezone                 = var.timezone
  upgrade                  = var.bastion_upgrade
  user                     = var.bastion_user

  # Standard tags as defined if enabled for use, or freeform
  # User-provided tags are merged last and take precedence
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace
  defined_tags = merge(var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = local.state_id,
    "${var.tag_namespace}.role"     = "bastion",
  } : {}, local.bastion_defined_tags)
  freeform_tags = merge(var.use_defined_tags ? {} : {
    "state_id" = local.state_id,
    "role"     = "bastion",
  }, local.bastion_freeform_tags)
}

output "bastion_id" {
  description = "ID of bastion instance"
  value       = one(module.bastion[*].id)
}

output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = local.bastion_public_ip
}

output "ssh_to_bastion" {
  description = "SSH command for bastion host"
  value       = local.bastion_ssh_command
}