# Copyright 2017, 2019 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# oci provider
variable "tenancy_id" {}

# general oci parameters
variable "compartment_id" {}

variable "label_prefix" {}

variable "region" {}

# ssh keys
variable "ssh_private_key" {}

variable "ssh_private_key_path" {}

variable "ssh_public_key" {}

variable "ssh_public_key_path" {}

# bastion
variable "create_bastion_host" {
  type = bool
}

variable "bastion_public_ip" {}

variable "bastion_user" {}

variable "bastion_state" {}

# operator
variable "create_operator" {
  type = bool
}

variable "operator_private_ip" {}

variable "operator_user" {}

variable "operator_state" {}

variable "operator_dynamic_group" {
  description = "name of dynamic group to allow updating dynamic-groups"
  type        = string
}

variable "enable_operator_instance_principal" {
  type = bool
}
variable "operator_os_version" {}

# oke
variable "cluster_id" {}

variable "cluster_name" {}

variable "pods_cidr" {}

# encryption
variable "use_cluster_encryption" {
  type = bool
}

variable "cluster_kms_key_id" {}


variable "cluster_kms_dynamic_group_id" {}

variable "create_policies" {
  type = bool
}

# ocir
variable "email_address" {}

variable "secret_id" {}

variable "secret_name" {}

variable "secret_namespace" {}

variable "username" {}

# calico
variable "calico_version" {}

variable "install_calico" {
  type = bool
}

variable "cni_type" {}
variable "calico_mode" {}
variable "calico_mtu" {}
variable "calico_url" {}
variable "calico_apiserver_enabled" {}
variable "typha_enabled" {}
variable "typha_replicas" {}
variable "calico_staging_dir" {}

#metricserver

variable "enable_metric_server" {
  default = false
  type    = bool
}

variable "enable_gatekeeper" {
  type    = bool
  default = false
}

variable "gatekeeper_version" {
  type = string

}
variable "enable_vpa" {
  type = bool
}
variable "vpa_version" {}

# service account
variable "create_service_account" {
  type = bool
}

variable "service_account_name" {}

variable "service_account_namespace" {}

variable "service_account_cluster_role_binding" {}

#check worker node active
variable "check_node_active" {
  type = string
}

# upgrade
variable "upgrade_nodepool" {
  type = bool
}

variable "nodepool_upgrade_method" {
  type = string
}

variable "node_pools_to_drain" {
  type = list(string)
}

variable "debug_mode" {
  type = bool
}
