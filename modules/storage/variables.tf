# Copyright 2017, 2019 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci parameters
variable "tenancy_id" {}

variable "compartment_id" {}

variable "label_prefix" {}

# fss instance availability domain
variable "availability_domain" {}

# fss mount target network name
variable "fss_subnet_id" {}

# fss nsg id
variable "nsg_ids" {}

# fss mount point network provisioning
variable "enable_fss" {}

# fss mount path
variable fss_mount_path {}
