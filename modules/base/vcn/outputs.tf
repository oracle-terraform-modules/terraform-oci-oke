# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "nat_gateway_id" {
  value = join(",", oci_core_nat_gateway.nat_gateway.*.id)
}

output "ig_route_id" {
  value = oci_core_route_table.ig_route.id
}

output "nat_route_id" {
  value = join(",", oci_core_route_table.nat_route.*.id)
}
