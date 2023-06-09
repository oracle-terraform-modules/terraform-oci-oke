# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  drg_attachments = (var.drg_attachments == null ? {}
    : { for k, v in var.drg_attachments : k => v if tobool(lookup(v, "create", true)) }
  )
}

// Create a DRG if any attachments are defined
resource "oci_core_drg" "oke" {
  count          = length(local.drg_attachments) > 0 ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "oke-${var.state_id}"
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [freeform_tags, defined_tags]
  }
}

// Attach the current VCN to the DRG
resource "oci_core_drg_attachment" "oke" {
  count         = length(local.drg_attachments) > 0 && length(oci_core_drg.oke[*]) > 0 ? 1 : 0
  drg_id        = one(oci_core_drg.oke[*].id)
  display_name  = "drg-oke-${var.state_id}"
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  network_details {
    id   = var.vcn_id
    type = "VCN"
  }

  lifecycle {
    ignore_changes = [freeform_tags, defined_tags]
  }
}

// Attach configured VCNs to the DRG
resource "oci_core_drg_attachment" "extra" {
  for_each      = local.drg_attachments
  drg_id        = one(oci_core_drg.oke[*].id)
  display_name  = format("%v-%v", each.key, var.state_id)
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  network_details {
    id   = lookup(each.value, "vcn_id")
    type = "VCN"
  }

  lifecycle {
    precondition {
      condition     = alltrue([for k, v in local.drg_attachments : contains(keys(v), "vcn_id")])
      error_message = "DRG attachments must specify a 'vcn_id'."
    }
    ignore_changes = [freeform_tags, defined_tags]
  }
}
