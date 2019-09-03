# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters

variable "oci_base_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_ocid     = string
    compartment_name     = string
    tenancy_ocid         = string
    user_ocid            = string
  })
}

# ssh keys

variable "oci_base_ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}

# general oci parameters

variable "oci_base_general" {
  type = object({
    disable_auto_retries = bool
    label_prefix         = string
    region               = string
  })
}

# networking parameters

variable "oci_base_vcn" {
  type = object({
    vcn_cidr               = string
    vcn_dns_name           = string
    vcn_name               = string
    create_nat_gateway     = bool
    nat_gateway_name       = string
    create_service_gateway = bool
    service_gateway_name   = string
  })
}

# bastion

variable "oci_base_bastion" {
  type = object({
    newbits                        = number
    subnets                        = number
    bastion_shape                  = string
    create_bastion                 = bool
    bastion_access                 = string
    enable_instance_principal      = bool
    image_ocid                     = string
    image_operating_system         = string
    image_operating_system_version = string
    availability_domains           = number
    package_update                 = bool
    package_upgrade                = bool
  })
}
