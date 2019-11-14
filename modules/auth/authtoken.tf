# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_auth_token" "ocirtoken" {
  provider    = "oci.home"
  description = "ocir auth token"
  user_id     = var.ocir.user_id
  count       = var.ocir.create_auth_token == true ? 1 : 0
}
