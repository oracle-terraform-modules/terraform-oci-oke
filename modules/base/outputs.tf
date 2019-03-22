# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl
output "vcn_id" {
  value = "${module.vcn.vcn_id}"
}

output "bastion_public_ips" {
  value = "${module.bastion.bastion_public_ips}"
}

output "ig_route_id" {
  value = "${module.vcn.ig_route_id}"
}

output "nat_route_id" {
  value = "${module.vcn.nat_route_id}"
}

output "sg_route_id" {
  value = "${module.vcn.sg_route_id}"
}

output "nat_gateway_id" {
  value = "${module.vcn.nat_gateway_id}"
}

output "ad_names" {
  value = "${data.template_file.ad_names.*.rendered}"
}

output "home_region" {
  value = "${lookup(data.oci_identity_regions.home_region.regions[0], "name")}"
}

# convenient output

output "ssh_to_bastion" {
  value = "${
    map(
      "AD1", "ssh -i ${var.ssh_private_key_path} opc@${module.bastion.bastion_public_ips["ad1"]}",
      "AD2", "ssh -i ${var.ssh_private_key_path} opc@${module.bastion.bastion_public_ips["ad2"]}",
      "AD3", "ssh -i ${var.ssh_private_key_path} opc@${module.bastion.bastion_public_ips["ad3"]}"
    )
  }"
}
