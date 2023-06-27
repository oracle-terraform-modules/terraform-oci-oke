# Copyright 2017, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_bastion              = true           # *true/false
bastion_allowed_cidrs       = []             # e.g. ["0.0.0.0/0"] to allow traffic from all sources
bastion_availability_domain = null           # Defaults to first available
bastion_image_id            = null           # Ignored when bastion_image_type = "platform"
bastion_image_os            = "Oracle Linux" # Ignored when bastion_image_type = "custom"
bastion_image_os_version    = "8"            # Ignored when bastion_image_type = "custom"
bastion_image_type          = "platform"     # platform/custom
bastion_nsg_ids             = []             # Combined with created NSG when enabled in var.nsgs
bastion_public_ip           = null           # Ignored when create_bastion = true
bastion_type                = "public"       # *public/private
bastion_upgrade             = false          # true/*false
bastion_user                = "opc"

bastion_shape = {
  shape            = "VM.Standard.E4.Flex",
  ocpus            = 1,
  memory           = 4,
  boot_volume_size = 50
}
