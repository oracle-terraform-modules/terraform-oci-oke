# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters

variable "oci_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_ocid     = string
    compartment_name     = string
    tenancy_ocid         = string
    user_ocid            = string
  })
}

variable "label_prefix" {}

variable "oke_kms" {
  type = object({
    use_encryption = bool
    key_id         = string
  })
}

variable "cluster_id" {}
