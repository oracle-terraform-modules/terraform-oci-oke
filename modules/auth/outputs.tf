# Copyright 2017, 2019 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "ocirtoken" {
  value = "${element(compact(concat(oci_identity_auth_token.ocirtoken.*.token, list("none"))),0)}"
}

output "ocirtoken_id" {
  value = "${element(compact(concat(oci_identity_auth_token.ocirtoken.*.id, list("none"))),0)}"
}
