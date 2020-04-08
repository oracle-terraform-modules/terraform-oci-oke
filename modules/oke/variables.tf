# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# identity

variable "oke_identity" {
  type = object({
    compartment_id = string
    user_id        = string
  })
}

# ssh keys

variable "oke_ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}

# general oci

variable "oke_general" {
  type = object({
    ad_names     = list(string)
    label_prefix = string
    region       = string
  })
}

# bastion

variable "oke_admin" {
  type = object({
    bastion_public_ip        = string
    admin_private_ip         = string
    bastion_enabled          = bool
    admin_enabled            = bool
    admin_instance_principal = bool
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
    auth_token        = string
    create_auth_token = bool
    email_address     = string
    ocirtoken_id      = string
    ocir_urls         = map(string)
    tenancy_name      = string
    username          = string
  })
}

# helm
variable "helm" {
  type = object({
    helm_version = string
    install_helm = bool
  })
}

# calico
variable "calico" {
  type = object({
    calico_version = string
    install_calico = bool
  })
}

#metricserver

variable "install_metricserver" {
  default = false
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
