# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bastion_public_ip" {
  value = "${join(",", data.oci_core_vnic.bastion_vnic.*.public_ip_address)}"
}

output "bastion_id" {
  value = "${join(",",data.oci_core_instance.bastion.*.id)}"
}