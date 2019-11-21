# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = var.oci_base_vcn.service_gateway_enabled == true ? 1 : 0
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.oci_base_vcn.compartment_id
  display_name   = "${var.oci_base_vcn.label_prefix}-sg-gw"
  depends_on     = [oci_core_nat_gateway.nat_gateway]

  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

  vcn_id = oci_core_vcn.vcn.id
  count  = var.oci_base_vcn.service_gateway_enabled == true ? 1 : 0
}
