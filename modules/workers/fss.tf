# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_file_storage_file_system" "fss" {
  count               = var.create_fss ? 1 : 0
  availability_domain = var.fss_availability_domain
  compartment_id      = var.compartment_id
  display_name        = "fss-${var.state_id}"
  lifecycle {
    ignore_changes = [availability_domain, defined_tags, display_name]
  }
}

resource "oci_file_storage_mount_target" "fss" {
  count               = var.create_fss ? 1 : 0
  availability_domain = var.fss_availability_domain
  compartment_id      = var.compartment_id
  subnet_id           = var.fss_subnet_id
  display_name        = "fss-${var.state_id}"
  hostname_label      = var.assign_dns ? "fss-mt" : null
  nsg_ids             = var.fss_nsg_ids

  lifecycle {
    ignore_changes = [availability_domain, defined_tags, display_name]
  }
}

resource "oci_file_storage_export_set" "fss" {
  count             = var.create_fss ? 1 : 0
  mount_target_id   = one(oci_file_storage_mount_target.fss[*].id)
  display_name      = "fss-${var.state_id}"
  max_fs_stat_bytes = var.fss_max_fs_stat_bytes
  max_fs_stat_files = var.fss_max_fs_stat_files
  lifecycle {
    ignore_changes = [display_name]
  }
}

resource "oci_file_storage_export" "fss" {
  count          = var.create_fss ? 1 : 0
  export_set_id  = one(oci_file_storage_export_set.fss[*].id)
  file_system_id = one(oci_file_storage_file_system.fss[*].id)
  path           = var.fss_mount_path
}

output "fss_mount_target_id" {
  value = one(oci_file_storage_mount_target.fss[*].id)
}

output "fss_id" {
  value = one(oci_file_storage_file_system.fss[*].id)
}
