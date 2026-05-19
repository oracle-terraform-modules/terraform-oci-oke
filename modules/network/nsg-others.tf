# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  custom_nsgs = { for k, v in var.nsgs : k => v if !contains(["bastion", "operator", "cp", "int_lb", "pub_lb", "workers", "pods", "fss"], k) }

  custom_nsgs_to_configure = { for k, v in local.custom_nsgs : k => v if
    alltrue([
      lookup(v, "create", "auto") != "never",
      lookup(v, "id", null) == null,
    ])
  }

  custom_nsgs_ids = { for k, v in local.custom_nsgs : k => coalesce(
    lookup(v, "id", null),
    lookup(lookup(oci_core_network_security_group.custom_nsgs, k, {}), "id", null)
  ) if lookup(v, "create", "auto") != "never" }

  custom_nsgs_rules = merge([
    for nsg_name, nsg in local.custom_nsgs : {
      for description, rule in lookup(nsg, "rules", {}) : "${nsg_name}###${description}" => merge(rule, {
        nsg_id = lookup(local.custom_nsgs_ids, nsg_name)
      })
    }
    if lookup(nsg, "create", "auto") != "never"
  ]...)
}

resource "oci_core_network_security_group" "custom_nsgs" {
  for_each = local.custom_nsgs_to_configure

  compartment_id = var.compartment_id
  display_name   = "${each.key}-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, vcn_id]
  }
}

output "custom_nsgs_ids" {
  value = local.custom_nsgs_ids
}
