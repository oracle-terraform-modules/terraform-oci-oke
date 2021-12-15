# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# mount target OCID for PVC definition
output "fss_mount_target_id" {
  value = oci_file_storage_mount_target.fss_mount_target.id
}
