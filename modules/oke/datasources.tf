# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = var.tenancy_id
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  node_pool_option_id = oci_containerengine_cluster.k8s_cluster.id
}