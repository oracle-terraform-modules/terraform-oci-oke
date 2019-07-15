# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "ocirtoken" {
  value = var.create_auth_token == true ? element(oci_identity_auth_token.ocirtoken.*.token, 0) : element(list(""), 0)
}

output "ocirtoken_id" {
  value = var.create_auth_token == true ? element(oci_identity_auth_token.ocirtoken.*.id, 0) : element(list(""), 0)
}
