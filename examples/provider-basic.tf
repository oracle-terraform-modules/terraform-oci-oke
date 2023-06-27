# Copyright 2017, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

provider "oci" {
  alias        = "home"
  region       = "us-ashburn-1"
  tenancy_ocid = "ocid1.tenancy..."
}

provider "oci" {
  region       = "ap-osaka-1"
  tenancy_ocid = "ocid1.tenancy..."
}
