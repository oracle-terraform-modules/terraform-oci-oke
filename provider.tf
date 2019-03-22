# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

provider "oci" {
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
  fingerprint          = "${var.api_fingerprint}"
  private_key_path     = "${var.api_private_key_path}"
  region               = "${var.region}"
  disable_auto_retries = "${var.disable_auto_retries}"
}
