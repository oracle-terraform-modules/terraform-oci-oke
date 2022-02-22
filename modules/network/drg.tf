# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "drg" {
  source  = "oracle-terraform-modules/vcn/oci//modules/drg"
  version = "3.2.0"

  compartment_id      = var.compartment_id
  label_prefix        = var.label_prefix
  drg_display_name    = var.drg_display_name
  drg_vcn_attachments = var.drg_vcn_attachments
  freeform_tags       = var.freeform_tags

  count = var.create_drg == true ? 1 : 0
}
