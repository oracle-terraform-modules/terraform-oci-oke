# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci
variable "compartment_id" {}

variable "label_prefix" {}

# bastion service parameters
variable "bastion_service_access" {
  type = list(string)
}

variable "bastion_service_name" {}

variable "bastion_service_target_subnet" {}

variable "vcn_id" {}