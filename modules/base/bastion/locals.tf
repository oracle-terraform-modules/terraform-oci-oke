# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Protocols are specified as protocol numbers.
# http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  all_protocols       = "all"
  anywhere            = "0.0.0.0/0"
  ssh_port            = 22
  tcp_protocol        = 6
  autonomous_image_id = lookup(data.oci_core_app_catalog_subscriptions.autonomous_linux[0].app_catalog_subscriptions[0], "listing_resource_id")
  oracle_image_id     = data.oci_core_images.oracle_images[0].images.0.id
  bastion_image_id    = var.oci_bastion.use_autonomous == true ? local.autonomous_image_id : (var.oci_bastion.bastion_image_id == "NONE" ? local.oracle_image_id : var.oci_bastion.bastion_image_id)
}
