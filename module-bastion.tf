# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// Used to retrieve available bastion images
data "oci_core_images" "bastion" {
  compartment_id           = local.compartment_id
  operating_system         = var.bastion_image_os
  operating_system_version = var.bastion_image_os_version
  shape                    = lookup(var.bastion_shape, "shape", "VM.Standard.E4.Flex")
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  bastion_public_ip = (var.create_bastion
    ? one(module.bastion[*].public_ip)
    : var.bastion_public_ip
  )

  bastion_image_id = (var.bastion_image_type == "custom"
    ? var.bastion_image_id : element(coalescelist(data.oci_core_images.bastion.images[*].id, ["none"]), 0)
  )
}

module "bastion" {
  count          = var.create_bastion ? 1 : 0
  source         = "./modules/bastion"
  state_id       = random_id.state_id.id
  compartment_id = local.compartment_id

  # Bastion
  assign_dns          = var.assign_dns
  availability_domain = coalesce(var.bastion_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  image_id            = local.bastion_image_id
  nsg_ids             = concat(var.bastion_nsg_ids, var.create_nsgs ? [module.network.bastion_nsg_id] : [])
  is_public           = var.bastion_is_public
  shape               = var.bastion_shape
  ssh_private_key     = local.ssh_private_key # to await cloud-init completion
  ssh_public_key      = local.ssh_public_key
  subnet_id           = lookup(module.network.subnet_ids, "bastion", lookup(module.network.subnet_ids, "pub_lb"))
  timezone            = var.timezone
  upgrade             = var.bastion_upgrade
  user                = var.bastion_user

  # Tagging
  defined_tags     = lookup(var.defined_tags, "bastion", {})
  freeform_tags    = lookup(var.freeform_tags, "bastion", {})
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

  providers = {
    oci.home = oci.home
  }
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
  value = (!var.create_bastion || local.bastion_public_ip == null ? null
    : "ssh${local.ssh_key_arg} ${var.bastion_user}@${local.bastion_public_ip}"
  )
}
