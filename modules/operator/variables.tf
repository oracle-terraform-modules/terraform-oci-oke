# Copyright (c) 2019, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }

# Bastion (to await cloud-init completion)
variable "bastion_host" { type = string }
variable "bastion_user" { type = string }

# Operator
variable "await_cloudinit" { type = string }
variable "assign_dns" { type = bool }
variable "availability_domain" { type = string }
variable "cloud_init" { type = list(map(string)) }
variable "image_id" { type = string }
variable "install_cilium" { type = bool }
variable "install_oci_cli_from_repo" { type = bool }
variable "install_helm" { type = bool }
variable "install_helm_from_repo" { type = bool }
variable "install_istioctl" { type = bool }
variable "install_k8sgpt" { type = bool }
variable "install_k9s" { type = bool }
variable "install_kubectl_from_repo" {
  type    = bool
  default = true
}
variable "install_kubectx" { type = bool }
variable "install_stern" { type = bool }
variable "kubeconfig" { type = string }
variable "kubernetes_version" { type = string }
variable "nsg_ids" { type = list(string) }
variable "operator_image_os_version" { type = string }
variable "pv_transit_encryption" { type = bool }
variable "shape" { type = map(any) }
variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" { type = string }
variable "subnet_id" { type = string }
variable "timezone" { type = string }
variable "upgrade" { type = bool }
variable "user" { type = string }
variable "volume_kms_key_id" { type = string }

# Tags
variable "defined_tags" { type = map(string) }
variable "freeform_tags" { type = map(string) }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = bool }