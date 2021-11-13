# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      # pass oci home region provider explicitly for identity operations
      configuration_aliases = [oci.home]
    }
  }
  required_version = ">= 1.0.0"
}

# Create file system
resource "oci_file_storage_file_system" "fss" {
    availability_domain = local.availability_domain
    compartment_id = var.compartment_id
    display_name = var.label_prefix == "none" ? "fss" : "${var.label_prefix}-fss"
    lifecycle {
      ignore_changes = [availability_domain, defined_tags]
    }
    count = (var.enable_fss == true) ? 1 : 0
}

# create file system mount target
resource "oci_file_storage_mount_target" "fss_mount_target" {
    availability_domain = local.availability_domain
    compartment_id      = var.compartment_id
    subnet_id           = var.fss_subnet_id
    display_name        = var.label_prefix == "none" ? "fss-mt" : "${var.label_prefix}-fss-mt"
    hostname_label      = var.label_prefix == "none" ? "fss-mt" : "${var.label_prefix}-fss-mt"
    nsg_ids             = var.nsg_ids

    lifecycle {
      ignore_changes = [availability_domain, defined_tags]
    }
    count = (var.enable_fss == true) ? 1 : 0
}

# FSS export set associate with mount target
resource "oci_file_storage_export_set" "export_sets" {
  mount_target_id   = oci_file_storage_mount_target.fss_mount_target[0].id
  display_name      = var.label_prefix == "none" ? "fss-storage-export" : "${var.label_prefix}-fss-storage-export"

  count = (var.enable_fss == true) ? 1 : 0
}

# FSS file storage export
resource "oci_file_storage_export" "exports" {
  export_set_id  = oci_file_storage_export_set.export_sets[0].id
  file_system_id = oci_file_storage_file_system.fss[0].id
  path           = var.fss_mount_path
  
  count = (var.enable_fss == true) ? 1 : 0
}