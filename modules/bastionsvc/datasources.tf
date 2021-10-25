# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_subnets" "bastion_svc_target_subnet" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? var.bastion_service_target_subnet : "${var.label_prefix}-${var.bastion_service_target_subnet}"
  vcn_id         = var.vcn_id
}
