# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

variable "oci_base_vcn" {
  type = object({
    compartment_id          = string
    label_prefix            = string
    nat_gateway_enabled     = bool
    service_gateway_enabled = bool
    vcn_cidr                = string
    vcn_dns_label           = string
    vcn_name                = string
  })
  description = "vcn basic parameters"
}
