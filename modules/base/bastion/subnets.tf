# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_subnet" "bastion" {
  compartment_id             = var.oci_base_identity.compartment_id
  cidr_block                 = cidrsubnet(var.oci_bastion_network.vcn_cidr, var.oci_bastion_network.newbits, var.oci_bastion_network.netnum)
  display_name               = "${var.oci_bastion_general.label_prefix}-bastion"
  dns_label                  = "bastion"
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.oci_bastion_network.ig_route_id
  security_list_ids          = [oci_core_security_list.bastion[0].id]
  vcn_id                     = var.oci_bastion_network.vcn_id

  count = var.oci_bastion.bastion_enabled == true ? 1 : 0
}
