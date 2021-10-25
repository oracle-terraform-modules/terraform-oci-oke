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

resource "oci_identity_dynamic_group" "oke_kms_cluster" {
  provider       = oci.home
  compartment_id = var.tenancy_id
  description    = "dynamic group to allow cluster to use KMS to encrypt etcd"
  matching_rule  = local.dynamic_group_rule_all_clusters
  name           = var.label_prefix == "none" ? "oke-kms-cluster" : "${var.label_prefix}-oke-kms-cluster"
  count          = var.use_encryption == true ? 1 : 0

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

resource "oci_identity_policy" "oke_kms" {
  provider       = oci.home
  compartment_id = var.compartment_id
  description    = "policy to allow dynamic group ${var.label_prefix}-oke-kms-cluster to use KMS to encrypt etcd"
  depends_on     = [oci_identity_dynamic_group.oke_kms_cluster]
  name           = var.label_prefix == "none" ? "oke-kms" : "${var.label_prefix}-oke-kms"
  statements     = [local.policy_statement]
  count          = var.use_encryption == true ? 1 : 0
}
