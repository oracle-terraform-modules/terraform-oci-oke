# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_security_list" "bastion" {
  compartment_id = var.oci_base_identity.compartment_id
  display_name   = "${var.oci_bastion_general.label_prefix}-bastion"
  vcn_id         = var.oci_bastion_infra.vcn_id

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
  }

  ingress_security_rules {
    # allow ssh
    protocol = local.tcp_protocol
    source   = var.oci_bastion.bastion_access == "ANYWHERE" ? local.anywhere : var.oci_bastion.bastion_access

    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }
  }
  count = var.oci_bastion.create_bastion == true ? 1 : 0
}
