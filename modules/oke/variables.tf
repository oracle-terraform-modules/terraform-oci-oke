# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# oci provider
variable "tenancy_id" {}

# general oci parameters
variable "compartment_id" {}

variable "label_prefix" {}

variable "region" {}

# ssh keys
variable "ssh_private_key_path" {}

variable "ssh_public_key_path" {}

# bastion
variable "bastion_public_ip" {}

variable "operator_private_ip" {}

variable "create_bastion_host" {
  type = bool
}
variable "create_operator" {
  type = bool
}
variable "operator_instance_principal" {
  type = bool
}
variable "operator_version" {}

variable "bastion_state" {}

# oke
variable "cluster_kubernetes_version" {}

variable "cluster_access" {}

variable "cluster_name" {}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  type = bool
}

variable "cluster_options_kubernetes_network_config_pods_cidr" {}

variable "cluster_options_kubernetes_network_config_services_cidr" {}

variable "cluster_subnets" {
  type = map(any)
}

variable "vcn_id" {}

# encryption
variable "use_encryption" {
  type = bool
}

variable "kms_key_id" {}

# signed images
variable "use_signed_images" {
  type = bool
}

variable "image_signing_keys" {
  type = list(any)
}

# admission controller options
variable "admission_controller_options" {
  type = map(any)
}

variable "node_pools" {
  type = any
}

variable "node_pool_name_prefix" {}

variable "node_pool_image_id" {}

variable "node_pool_os" {}

variable "node_pool_os_version" {}

variable "preferred_lb_subnets" {}


# ocir
variable "email_address" {}

variable "ocir_urls" {
  type = map(any)
}

variable "secret_id" {}

variable "secret_name" {}

variable "username" {}

# calico
variable "calico_version" {}

variable "install_calico" {
  type = bool
}

#metricserver

variable "metricserver_enabled" {
  default = false
  type    = bool
}

variable "vpa_enabled" {
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
variable "nodepool_drain" {
  type = bool
}

variable "nodepool_upgrade_method" {
  type = string
}

variable "node_pools_to_drain" {
  type = list(string)
}
