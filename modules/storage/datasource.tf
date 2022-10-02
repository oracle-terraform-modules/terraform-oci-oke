# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# query ADs
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = var.availability_domain
}

data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}
