# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

provider "oci" {
  alias        = "home"
  region       = one(data.oci_identity_region_subscriptions.home.region_subscriptions[*].region_name)
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.current_user_ocid
}

provider "oci" {
  region                 = var.region
  tenancy_ocid           = var.tenancy_ocid
  user_ocid              = var.current_user_ocid
  retry_duration_seconds = 1800
}
