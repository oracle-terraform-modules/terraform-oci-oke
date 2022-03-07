# Copyright 2017, 2019 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# general oci parameters
variable "tenancy_id" {}

variable "compartment_id" {}

variable "label_prefix" {}

# fss instance availability domain
variable "availability_domain" {}

# fss subnets
variable "subnets" {
  type = map(any)
}

variable "vcn_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "nat_route_id" {}

# fss mount path
variable "fss_mount_path" {}

# Controls the maximum tbytes, fbytes, and abytes, values reported by NFS FSSTAT calls through any associated mount targets.
variable "max_fs_stat_bytes" {}

# Controls the maximum tfiles, ffiles, and afiles values reported by NFS FSSTAT calls through any associated mount targets.
variable "max_fs_stat_files" {}
