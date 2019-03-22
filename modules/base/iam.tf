# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
}

# get the tenancy's home region
data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

# create a home region provider for identity operations
provider "oci" {
  alias            = "home"
  region           = "${lookup(data.oci_identity_regions.home_region.regions[0], "name")}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.api_fingerprint}"
  private_key_path = "${var.api_private_key_path}"
}

# data "oci_identity_compartments" "compartments_name" {
#   compartment_id = "${var.tenancy_ocid}"
#   compartment_id_in_subtree  = "true"
#   access_level = "ANY"

#   filter {
#     name   = "name"
#     values = ["${var.compartment_name}"]
#   }
# }

# resource "oci_identity_dynamic_group" "instance_principal" {
#   provider       = "oci.home"
#   compartment_id = "${var.tenancy_ocid}"
#   name           = "${var.label_prefix}-instance_principal"
#   description    = "dynamic group to allow instances to call services"
#   matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
#   count          = "${(var.enable_instance_principal == "true") ? "1" : "0"}"
# }

# resource "oci_identity_policy" "instance_principal" {
#   provider       = "oci.home"
#   name           = "${var.label_prefix}-instance_principal"
#   description    = "dynamic group to allow instances to call services"
#   compartment_id = "${var.compartment_ocid}"
#   statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.instance_principal.name} to manage all-resources in compartment ${data.oci_identity_compartments.compartments_name.compartments.0.name}"]
#   count          = "${(var.enable_instance_principal == "true") ? "1" : "0"}"
# }
