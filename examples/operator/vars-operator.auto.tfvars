# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_operator                = true # *true/false
operator_availability_domain   = null
operator_cloud_init            = []
operator_image_id              = null           # Ignored when operator_image_type = "platform"
operator_image_os              = "Oracle Linux" # Ignored when operator_image_type = "custom"
operator_image_os_version      = "8"            # Ignored when operator_image_type = "custom"
operator_image_type            = "platform"
operator_nsg_ids               = []
operator_private_ip            = null
operator_pv_transit_encryption = false # true/*false
operator_upgrade               = false # true/*false
operator_user                  = "opc"
operator_volume_kms_key_id     = null

operator_shape = {
  shape            = "VM.Standard.E4.Flex",
  ocpus            = 1,
  memory           = 4,
  boot_volume_size = 50
}
