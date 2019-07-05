# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_ocid" {}

variable "label_prefix" {}

# nat

variable "create_nat_gateway" {}

variable "nat_gateway_name" {}

# service gateway

variable "create_service_gateway" {}

variable "service_gateway_name" {}

# vcn

variable "vcn_cidr" {}

variable "vcn_dns_name" {}

variable "vcn_name" {}
