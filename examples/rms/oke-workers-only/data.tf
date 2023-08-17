# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "ssh_public_key" {
  default = null
  type    = string
}

data "oci_identity_region_subscriptions" "home" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

locals {
  ssh_public_key = try(base64decode(var.ssh_public_key), var.ssh_public_key)
}
