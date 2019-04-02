# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# create a home region provider for identity operations
provider "oci" {
  alias            = "home"
  fingerprint      = "${var.api_fingerprint}"
  private_key_path = "${var.api_private_key_path}"
  region           = "${var.home_region}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
}
