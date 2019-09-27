# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# create a home region provider for identity operations
provider "oci" {
  alias            = "home"
  fingerprint      = var.ocir.api_fingerprint
  private_key_path = var.ocir.api_private_key_path
  region           = var.ocir.home_region
  tenancy_ocid     = var.ocir.tenancy_id
  user_ocid        = var.ocir.user_id
}
