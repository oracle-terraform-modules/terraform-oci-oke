# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// Used to retrieve available operator images
data "oci_core_images" "operator" {
  compartment_id           = local.compartment_id
  operating_system         = var.operator_image_os
  operating_system_version = var.operator_image_os_version
  shape                    = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  // The private IP of the operator instance, whether created in this TF state or existing provided by ID
  operator_private_ip = (local.cluster_enabled && var.create_operator
    ? one(module.operator[*].private_ip)
    : var.operator_private_ip
  )

  // Whether the operator is enabled, i.e. created in this TF state or existing provided by ID
  operator_enabled = alltrue([
    (local.cluster_enabled || coalesce(var.cluster_id, "none") != "none"),
    (var.create_operator || coalesce(var.operator_private_ip, "none") != "none"),
  ])

  // The resolved image ID for the created operator instance
  operator_image_id = var.create_operator ? (var.operator_image_type == "custom"
    ? var.operator_image_id
    : element(coalescelist(data.oci_core_images.operator.images[*].id, ["none"]), 0)
  ) : null
}

module "operator" {
  count          = var.create_operator ? 1 : 0
  source         = "./modules/operator"
  state_id       = local.state_id
  compartment_id = local.compartment_id

  # Bastion (to await cloud-init completion)
  bastion_host = local.bastion_public_ip
  bastion_user = var.bastion_user

  # Operator
  assign_dns            = var.assign_dns
  availability_domain   = coalesce(var.operator_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  cloud_init            = var.operator_cloud_init
  image_id              = local.operator_image_id
  install_helm          = var.operator_install_helm
  install_k9s           = var.operator_install_k9s
  install_kubectx       = var.operator_install_kubectx
  kubeconfig            = yamlencode(local.kubeconfig_private)
  kubernetes_version    = var.kubernetes_version
  nsg_ids               = concat(var.operator_nsg_ids, var.create_nsgs ? [module.network.operator_nsg_id] : [])
  pv_transit_encryption = var.operator_pv_transit_encryption
  shape                 = var.operator_shape
  ssh_private_key       = sensitive(local.ssh_private_key) # to await cloud-init completion
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
