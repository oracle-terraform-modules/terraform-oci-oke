# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "create_operator" {
  default     = true
  description = "Whether to create an operator server in a private subnet."
  type        = bool
}

variable "operator_availability_domain" {
  default     = null
  description = "The availability domain for FSS placement. Defaults to first available."
  type        = string
}

variable "operator_cloud_init" {
  default     = []
  description = "List of maps containing cloud init MIME part configuration for operator host. See https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config.html#part for expected schema of each element."
  type        = list(map(string))
}

variable "operator_nsg_ids" {
  description = "An optional and updatable list of network security groups that the operator will be part of."
  default     = []
  type        = list(string)
}

variable "operator_user" {
  default     = "opc"
  description = "User for SSH access to operator host."
  type        = string
}

variable "operator_image_id" {
  default     = null
  description = "Image ID for created operator instance."
  type        = string
}

variable "operator_image_os" {
  default     = "Oracle Linux"
  description = "Operator image operating system name when operator_image_type = 'platform'."
  type        = string
}

variable "operator_image_os_version" {
  default     = "8"
  description = "Operator image operating system version when operator_image_type = 'platform'."
  type        = string
}

variable "operator_image_type" {
  default     = "platform"
  description = "Whether to use a platform or custom image for the created operator instance. When custom is set, the operator_image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "platform"], var.operator_image_type)
    error_message = "Accepted values are custom or platform"
  }
}

variable "operator_install_helm" {
  default     = true
  description = "Whether to install Helm on the created operator host."
  type        = bool
}

variable "operator_install_helm_from_repo" {
  default     = false
  description = "Whether to install Helm from the repo on the created operator host."
  type        = bool
}

variable "operator_install_oci_cli_from_repo" {
  default     = false
  description = "Whether to install OCI from repo on the created operator host."
  type        = bool
}

variable "operator_install_istioctl" {
  default     = false
  description = "Whether to install istioctl on the created operator host."
  type        = bool
}

variable "operator_install_k8sgpt" {
  default     = false
  description = "Whether to install k8sgpt on the created operator host. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "operator_install_k9s" {
  default     = false
  description = "Whether to install k9s on the created operator host. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "operator_install_kubectl_from_repo" {
  default     = true
  description = "Whether to install kubectl from the repo on the created operator host."
  type        = bool
}

variable "operator_install_kubectx" {
  default     = true
  description = "Whether to install kubectx/kubens on the created operator host. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "operator_install_stern" {
  default     = false
  description = "Whether to install stern on the created operator host. NOTE: Provided only as a convenience and not supported by or sourced from Oracle - use at your own risk."
  type        = bool
}

variable "operator_shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  description = "Shape of the created operator instance."
  type        = map(any)
}

variable "operator_volume_kms_key_id" {
  default     = null
  description = "The OCID of the OCI KMS key to assign as the master encryption key for the boot volume."
  type        = string
}

variable "operator_pv_transit_encryption" {
  default     = false
  description = "Whether to enable in-transit encryption for the data volume's paravirtualized attachment."
  type        = bool
}

variable "operator_upgrade" {
  default     = false
  description = "Whether to upgrade operator packages after provisioning."
  type        = bool
}

variable "operator_private_ip" {
  default     = null
  description = "The IP address of an existing operator host. Ignored when create_operator = true."
  type        = string
}

variable "operator_await_cloudinit" {
  default     = true
  description = "Whether to block until successful connection to operator and completion of cloud-init."
  type        = bool
}