# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Protocols are specified as protocol numbers.
# http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  tcp_protocol  = 6
  all_protocols = "all"

  anywhere = "0.0.0.0/0"

  ssh_port = 22
}

resource "oci_core_security_list" "bastion" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.label_prefix}-bastion"
  vcn_id         = var.vcn_id

  egress_security_rules {
      protocol    = local.all_protocols
      destination = local.anywhere
  }

  ingress_security_rules {
      # allow ssh
      protocol = local.tcp_protocol
      source   = var.bastion_access == "ANYWHERE" ? local.anywhere : var.bastion_access

      tcp_options {
        min = local.ssh_port
        max = local.ssh_port
      }
    }
  count = var.create_bastion == true ? 1 :0  
}
