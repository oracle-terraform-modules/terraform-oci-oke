# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ocid" {}

variable "tenancy_ocid" {}

variable "user_ocid" {}

variable "ssh_private_key_path" {}

variable "ssh_public_key_path" {}

variable "region" {}

variable "availability_domains" {
  type = "map"
}

variable "ad_names" {
  type = "list"
}

variable "label_prefix" {}

variable "preferred_bastion_image" {}
variable "bastion_public_ips" {
  type = "map"
}

variable "vcn_id" {}

variable "cluster_subnets" {
  type = "map"
}

variable "cluster_kubernetes_version" {}

variable "cluster_name" {}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {}

variable "cluster_options_add_ons_is_tiller_enabled" {}

variable "cluster_options_kubernetes_network_config_pods_cidr" {}

variable "cluster_options_kubernetes_network_config_services_cidr" {}

variable "node_pool_name_prefix" {}

variable "node_pool_node_image_name" {}

variable "node_pool_node_shape" {}

variable "node_pool_quantity_per_subnet" {}

variable "node_pools" {}

variable "nodepool_topology" {}

variable "cluster_kube_config_expiration" {
  default = 2592000
}

variable "cluster_kube_config_token_version" {
  default = "1.0.0"
}

variable "ocir_urls" {
  type        = "map"
}

variable "tenancy_name" {}

variable "username" {}

variable "email_address" {}

variable "create_auth_token" {}
variable "auth_token" {}

variable "ocirtoken_id" {}

variable "install_helm" {}

variable "helm_version" {}

variable "install_ksonnet" {}

variable "ksonnet_version" {}
variable "install_calico" {
  default = "false"
}

variable "calico_version" {}
