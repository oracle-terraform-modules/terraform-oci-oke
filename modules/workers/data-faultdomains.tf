# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_fault_domains" "all" {
  for_each            = var.ad_numbers_to_names
  availability_domain = each.value
  compartment_id      = var.compartment_id
}
