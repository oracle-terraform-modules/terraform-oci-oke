# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# create a home region provider for identity operations
provider "oci" {
  alias            = "home"
  fingerprint      = var.oci_admin_identity.api_fingerprint
  private_key_path = var.oci_admin_identity.api_private_key_path
  region           = var.oci_admin_general.home_region
  tenancy_ocid     = var.oci_admin_identity.tenancy_id
  user_ocid        = var.oci_admin_identity.user_id
}

data "oci_identity_compartments" "compartments_id" {
  access_level              = "ACCESSIBLE"
  compartment_id            = var.oci_admin_identity.tenancy_id
  compartment_id_in_subtree = "true"

  filter {
    name   = "id"
    values = [var.oci_admin_identity.compartment_id]
  }
}

resource "oci_identity_dynamic_group" "admin_instance_principal" {
  provider       = oci.home
  compartment_id = var.oci_admin_identity.tenancy_id
  description    = "dynamic group to allow instances to call services for 1 admin"
  matching_rule  = "ALL {instance.id = '${join(",", data.oci_core_instance.admin.*.id)}'}"
  name           = "${var.oci_admin_general.label_prefix}-admin_instance_principal"
  count          = var.oci_admin.admin_enabled == true && var.oci_admin.enable_instance_principal == true ? 1 : 0
}

resource "oci_identity_policy" "admin_instance_principal" {
  provider       = oci.home
  compartment_id = var.oci_admin_identity.compartment_id
  description    = "policy to allow admin host to call services"
  name           = "${var.oci_admin_general.label_prefix}-admin_instance_principal"
  statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.admin_instance_principal[0].name} to manage all-resources in compartment id ${data.oci_identity_compartments.compartments_id.compartments.0.id}"]
  count          = var.oci_admin.admin_enabled == true && var.oci_admin.enable_instance_principal == true ? 1 : 0
}
