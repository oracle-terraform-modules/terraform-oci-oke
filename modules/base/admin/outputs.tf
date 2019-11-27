# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "admin_private_ip" {
  value = join(",", data.oci_core_vnic.admin_vnic.*.private_ip_address)
}

output "admin_instance_principal_group_name" {
  value = var.oci_admin.admin_enabled == true && var.oci_admin.enable_instance_principal == true ? oci_identity_dynamic_group.admin_instance_principal[0].name : null
}
