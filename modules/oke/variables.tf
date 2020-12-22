# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci parameters
variable "compartment_id" {}

variable "label_prefix" {}

# region parameters
variable "ad_names" {
  type = list(string)
}
variable "region" {}

# ssh keys

variable "oke_ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}

# bastion

variable "oke_operator" {
  type = object({
    bastion_public_ip           = string
    operator_private_ip         = string
    bastion_enabled             = bool
    operator_enabled            = bool
    operator_instance_principal = bool
  })
}

# oke

variable "oke_cluster" {
  type = object({
    cluster_kubernetes_version                              = string
    cluster_name                                            = string
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = bool
    cluster_options_kubernetes_network_config_pods_cidr     = string
    cluster_options_kubernetes_network_config_services_cidr = string
    cluster_subnets                                         = map(string)
    vcn_id                                                  = string

    # encryption
    use_encryption = bool
    kms_key_id     = string

    # admission controller options
    admission_controller_options = map(bool)
  })
}

variable "node_pools" {
  type = object({
    node_pools            = map(any)
    node_pool_name_prefix = string
    node_pool_image_id    = string
    node_pool_os          = string
    node_pool_os_version  = string
  })
}

variable "lbs" {
  type = object({
    preferred_lb_subnets = string
  })
}

# ocir
variable "oke_ocir" {
  type = object({
    email_address = string
    ocir_urls     = map(string)
    secret_id     = string
    secret_name   = string
    tenancy_name  = string
    username      = string
  })
}

variable "calico_enabled" {
  default = false
  type    = bool
}

#metricserver

variable "metricserver_enabled" {
  default = false
  type    = bool
}

variable "vpa" {
  type = object({
    enabled = bool
    version = string
  })
}

# service account

variable "service_account" {
  type = object({
    create_service_account               = bool
    service_account_name                 = string
    service_account_namespace            = string
    service_account_cluster_role_binding = string
  })
}

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
