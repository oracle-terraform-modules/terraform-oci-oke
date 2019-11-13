# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# general

variable "oci_admin_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_id       = string
    tenancy_id           = string
    user_id              = string
  })
}

variable "oci_admin_general" {
  type = object({
    home_region  = string
    label_prefix = string
    region       = string
  })
}

# admin

variable "oci_admin" {
  type = object({
    admin_image_id      = string
    admin_shape         = string
    admin_upgrade       = bool
    create_admin        = bool
    ssh_public_key_path = string
    timezone            = string
  })
}

variable "oci_admin_network" {
  type = object({
    ad_names             = list(string)
    availability_domains = number
    nat_route_id         = string
    netnum               = number
    newbits              = number
    vcn_cidr             = string
    vcn_id               = string
  })
}

variable "oci_admin_notification" {
  type = object({
    enable_notification = bool
    notification_endpoint  = string
    notification_protocol  = string
    notification_topic     = string

  })
}
