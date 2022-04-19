# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Create file system
resource "oci_file_storage_file_system" "fss" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_id
  display_name        = var.label_prefix == "none" ? "fss" : "${var.label_prefix}-fss"
  lifecycle {
    ignore_changes = [availability_domain, defined_tags]
  }
}

# create file system mount target
resource "oci_file_storage_mount_target" "fss_mount_target" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_id
  subnet_id           = oci_core_subnet.fss.id
  display_name        = var.label_prefix == "none" ? "fss-mt" : "${var.label_prefix}-fss-mt"
  hostname_label      = "fss-mt"
  nsg_ids             = [oci_core_network_security_group.fss_mt.id]

  lifecycle {
    ignore_changes = [availability_domain, defined_tags]
  }
}

# FSS export set associate with mount target
resource "oci_file_storage_export_set" "export_sets" {
  mount_target_id   = oci_file_storage_mount_target.fss_mount_target.id
  display_name      = var.label_prefix == "none" ? "fss-storage-export" : "${var.label_prefix}-fss-storage-export"
  max_fs_stat_bytes = var.max_fs_stat_bytes
  max_fs_stat_files = var.max_fs_stat_files
}

# FSS file storage export
resource "oci_file_storage_export" "exports" {
  export_set_id  = oci_file_storage_export_set.export_sets.id
  file_system_id = oci_file_storage_file_system.fss.id
  path           = var.fss_mount_path
}
