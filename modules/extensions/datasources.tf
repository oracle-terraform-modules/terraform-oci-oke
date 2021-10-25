# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_id
}

# get the tenancy's home region
data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_containerengine_node_pools" "all_node_pools" {
  compartment_id = var.compartment_id
  cluster_id     = var.cluster_id
}

data "oci_containerengine_node_pool_option" "node_pool_options" {
  node_pool_option_id = var.cluster_id
}

# retrieve object storage namespace for creating ocir secret
data "oci_objectstorage_namespace" "object_storage_namespace" {
}

