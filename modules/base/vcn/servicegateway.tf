# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_services" "oci_services_object_storage" {
  filter {
    name   = "name"
    values = [".*Object.*Storage"]
    regex  = true
  }
    count = "${(var.create_service_gateway == "true") ? 1 : 0}"
}

data "oci_core_service_gateways" "service_gateways" {
  #Required
  compartment_id = "${var.compartment_ocid}"

  #Optional
  state  = "${var.service_gateway_state}"
  vcn_id = "${oci_core_vcn.vcn.id}"
    count = "${(var.create_service_gateway == "true") ? 1 : 0}"
}

resource "oci_core_service_gateway" "service_gateway" { 
  depends_on = ["oci_core_nat_gateway.nat_gateway"]
  compartment_id = "${var.compartment_ocid}"

  services {
    service_id = "${lookup(data.oci_core_services.oci_services_object_storage.services[0], "id")}"
  }

  vcn_id = "${oci_core_vcn.vcn.id}"

  display_name = "${var.label_prefix}-${var.service_gateway_name}"

  count = "${(var.create_service_gateway == "true") ? 1 : 0}"
}

resource "oci_core_route_table" "service_gateway_route" {
  depends_on = ["oci_core_route_table.nat_route"]
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.vcn.id}"
  display_name   = "${var.label_prefix}-service_gateway_route"

  route_rules {
    destination       = "${lookup(data.oci_core_services.oci_services_object_storage.services[0], "cidr_block")}"
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = "${oci_core_service_gateway.service_gateway.id}"
  }

  count = "${(var.create_service_gateway == "true") ? 1 : 0}"
}
