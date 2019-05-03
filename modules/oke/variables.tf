# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# identity
variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "user_ocid" {}

# ssh keys
variable "ssh_private_key_path" {}

variable "ssh_public_key_path" {}

# general oci

variable "ad_names" {
  type = "list"
}

variable "label_prefix" {}

variable "region" {}

# availability domains
variable "availability_domains" {
  type = "map"
}


# bastion
variable "bastion_public_ip" {}

variable "create_bastion" {}

variable "enable_instance_principal" {}

variable "image_operating_system" {}

# networking
variable "vcn_id" {}

# oke

variable "cluster_kubernetes_version" {}

variable "cluster_name" {}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {}

variable "cluster_options_add_ons_is_tiller_enabled" {}

variable "cluster_options_kubernetes_network_config_pods_cidr" {}

variable "cluster_options_kubernetes_network_config_services_cidr" {}

variable "cluster_subnets" {
  type = "map"
}

variable "node_pools" {}

variable "node_pool_name_prefix" {}

variable "node_pool_node_image_name" {}

variable "node_pool_node_shape" {}

variable "node_pool_quantity_per_subnet" {}

variable "nodepool_topology" {}

# kubeconfig
variable "cluster_kube_config_expiration" {
  default = 2592000
}
variable "cluster_kube_config_token_version" {
  default = "1.0.0"
}

# ocir
variable "auth_token" {}
variable "create_auth_token" {}

variable "email_address" {}

variable "ocirtoken_id" {}

variable "ocir_urls" {
  type        = "map"
}

variable "tenancy_name" {}

variable "username" {}


# helm
variable "helm_version" {}

variable "install_helm" {}

# calico
variable "calico_version" {}

variable "install_calico" {
  default = false
}