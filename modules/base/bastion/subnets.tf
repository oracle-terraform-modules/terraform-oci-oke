# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# bastion

resource "oci_core_subnet" "bastion" {
  compartment_id             = "${var.compartment_ocid}"
  cidr_block                 = "${cidrsubnet(var.vcn_cidr,var.newbits["bastion"],var.subnets["bastion"])}"
  display_name               = "${var.label_prefix}-bastion"
  dns_label                  = "bastion"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = "${var.ig_route_id}"
  security_list_ids          = ["${oci_core_security_list.bastion.id}"]
  vcn_id                     = "${var.vcn_id}"

  count = "${var.create_bastion == true ? 1 :0}"
}
