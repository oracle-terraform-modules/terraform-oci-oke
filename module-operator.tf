# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// Used to retrieve available operator images when enabled
data "oci_core_images" "operator" {
  count                    = var.create_operator ? 1 : 0
  compartment_id           = local.compartment_id
  operating_system         = var.operator_image_os
  operating_system_version = var.operator_image_os_version
  shape                    = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "launch_mode"
    values = ["NATIVE"]
  }
}

locals {
  // The private IP of the operator instance, whether created in this TF state or existing provided by ID
  operator_private_ip = (local.cluster_enabled && var.create_operator && length(module.operator) > 0
    ? lookup(element(module.operator, 0), "private_ip", var.operator_private_ip)
    : var.operator_private_ip
  )

  // Whether the operator is enabled, i.e. created in this TF state or existing provided by ID
  operator_enabled = anytrue([
    (local.cluster_enabled || coalesce(var.cluster_id, "none") != "none"),
    (var.create_operator || coalesce(var.operator_private_ip, "none") != "none"),
  ])

  // The resolved image ID for the created operator instance
  operator_images    = try(data.oci_core_images.operator[0].images, tolist([])) # Data source result or empty
  operator_image_ids = local.operator_images[*].id                              # Image OCIDs from data source
  operator_image_id = (var.operator_image_type == "custom"
    ? var.operator_image_id : element(coalescelist(local.operator_image_ids, ["none"]), 0)
  )

  # Operator SSH command args for.ssh_to_operator output if created/provided
  operator_ssh_user_ip = join("@", compact([var.operator_user, local.operator_private_ip]))
  operator_ssh_args    = compact([local.ssh_key_arg, local.operator_ssh_user_ip])
}

module "operator" {
  count          = var.create_bastion && var.create_operator ? 1 : 0
  source         = "./modules/operator"
  state_id       = local.state_id
  compartment_id = local.compartment_id

  # Bastion (to await cloud-init completion)
  bastion_host = local.bastion_public_ip
  bastion_user = var.bastion_user

  # Operator
  await_cloudinit           = var.operator_await_cloudinit
  assign_dns                = var.assign_dns
  availability_domain       = coalesce(var.operator_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  cloud_init                = var.operator_cloud_init
  image_id                  = local.operator_image_id
  install_cilium            = var.cilium_install
  install_helm              = var.operator_install_helm
  install_helm_from_repo    = var.operator_install_helm_from_repo
  install_oci_cli_from_repo = var.operator_install_oci_cli_from_repo
  install_istioctl          = var.operator_install_istioctl
  install_k8sgpt            = var.operator_install_k8sgpt
  install_k9s               = var.operator_install_k9s
  install_kubectx           = var.operator_install_kubectx
  install_kubectl_from_repo = var.operator_install_kubectl_from_repo
  install_stern             = var.operator_install_stern
  kubeconfig                = yamlencode(local.kubeconfig_private)
  kubernetes_version        = var.kubernetes_version
  nsg_ids                   = compact(flatten([var.operator_nsg_ids, try(module.network.operator_nsg_id, null)]))
  operator_image_os_version = var.operator_image_os_version
  pv_transit_encryption     = var.operator_pv_transit_encryption
  shape                     = var.operator_shape
  ssh_private_key           = sensitive(local.ssh_private_key) # to await cloud-init completion
  ssh_public_key            = local.ssh_public_key
  subnet_id                 = try(module.network.operator_subnet_id, "") # safe destroy; validated in submodule
  timezone                  = var.timezone
  upgrade                   = var.operator_upgrade
  user                      = var.operator_user
  volume_kms_key_id         = var.operator_volume_kms_key_id


  # Standard tags as defined if enabled for use, or freeform
  # User-provided tags are merged last and take precedence
  defined_tags = merge(var.use_defined_tags ? {
    "${var.tag_namespace}.state_id" = local.state_id,
    "${var.tag_namespace}.role"     = "operator",
  } : {}, local.operator_defined_tags)
  freeform_tags = merge(var.use_defined_tags ? {} : {
    "state_id" = local.state_id,
    "role"     = "operator",
  }, local.operator_freeform_tags)
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

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
  value = local.operator_enabled ? join(" ", concat(["ssh"],
    local.bastion_proxy_command, local.operator_ssh_args)
  ) : null
}