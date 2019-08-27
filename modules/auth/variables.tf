# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "ocir" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_ocid     = string
    create_auth_token    = bool
    home_region          = string
    tenancy_ocid         = string
    user_ocid            = string
  })
}