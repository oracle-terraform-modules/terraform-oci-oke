# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "oci_base_vcn" {
  type = object({
    compartment_ocid       = string
    label_prefix           = string
    create_nat_gateway     = bool
    nat_gateway_name       = string
    create_service_gateway = bool
    service_gateway_name   = string
    vcn_cidr               = string
    vcn_dns_name           = string
    vcn_name               = string
  })
}