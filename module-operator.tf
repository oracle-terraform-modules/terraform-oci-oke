# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  operator_private_ip = (var.create_cluster && var.create_operator
    ? one(module.operator[*].private_ip)
    : var.operator_private_ip
  )

  operator_enabled = alltrue([
    (var.create_cluster || coalesce(var.cluster_id, "none") != "none"),
    (var.create_operator || coalesce(var.operator_private_ip, "none") != "none"),
  ])

  operator_image_id = (var.operator_image_type == "custom"
    ? var.operator_image_id : element(tolist(setintersection([
      lookup(local.image_ids, format("%s %s", var.operator_image_os, split(".", var.operator_image_os_version)[0]), null),
      local.image_ids.nongpu, local.image_ids.x86_64,
    ]...)), 0)
  )
}

module "operator" {
  count          = local.operator_enabled ? 1 : 0
  source         = "./modules/operator"
  state_id       = random_id.state_id.id
  compartment_id = local.compartment_id

  # Operator
  assign_dns            = var.assign_dns
  availability_domain   = coalesce(var.operator_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  image_id              = local.operator_image_id
  kubernetes_version    = var.kubernetes_version
  nsg_ids               = concat(var.operator_nsg_ids, var.create_nsgs ? [module.network.operator_nsg_id] : [])
  pv_transit_encryption = var.operator_pv_transit_encryption
  shape                 = var.operator_shape
  ssh_public_key        = local.ssh_public_key
  subnet_id             = lookup(module.network.subnet_ids, "operator", lookup(module.network.subnet_ids, "workers"))
  timezone              = var.timezone
  upgrade               = var.operator_upgrade
  user                  = var.operator_user
  volume_kms_key_id     = var.operator_volume_kms_key_id

  # Tagging
  defined_tags     = lookup(var.defined_tags, "operator", {})
  freeform_tags    = lookup(var.freeform_tags, "operator", {})
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

  providers = {
    oci.home = oci.home
  }

  depends_on = [
    module.iam,
  ]
}

output "operator_id" {
  description = "ID of operator instance"
  value       = one(module.operator[*].id)
}

output "operator_private_ip" {
  description = "Private IP address of operator host"
  value       = local.operator_private_ip
}

output "ssh_to_operator" {
  description = "SSH command for operator host"
  value = (local.operator_enabled || coalesce(var.operator_private_ip, "none") != "none"
    ? "ssh${local.ssh_key_arg} -J ${var.bastion_user}@${local.bastion_public_ip} ${var.operator_user}@${local.operator_private_ip}" : null
  )
}
