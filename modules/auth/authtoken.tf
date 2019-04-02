# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_auth_token" "ocirtoken" {
  provider    = "oci.home"
  description = "ocir auth token"
  user_id     = "${var.user_ocid}"
  count       = "${(var.create_auth_token == true) ? 1 : 0}"
}
