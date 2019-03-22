# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad_list.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad_list.availability_domains[count.index], "name")}"
}
