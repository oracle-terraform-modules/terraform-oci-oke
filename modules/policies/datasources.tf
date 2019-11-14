# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.oci_identity.tenancy_id  
}

# get the tenancy's home region
data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_identity_compartments" "compartments_id" {
  access_level              = "ACCESSIBLE"
  compartment_id            = var.oci_identity.tenancy_id
  compartment_id_in_subtree = "true"

  filter {
    name   = "id"
    values = [var.oci_identity.compartment_id]
  }
}
