# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "bastion_public_ip" {
  value = join(",", data.oci_core_vnic.bastion_vnic.*.public_ip_address)
}

output "bastion_instance_principal_group_name" {
  value = (var.oci_bastion.enable_instance_principal == true) ? oci_identity_dynamic_group.bastion_instance_principal[0].name : null
}
