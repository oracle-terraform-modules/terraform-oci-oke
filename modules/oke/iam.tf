# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      # pass oci home region provider explicitly for identity operations
      configuration_aliases = [oci.home]
      version               = ">= 4.67.3"
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
  count          = var.use_cluster_encryption == true && var.create_policies == true ? 1 : 0


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


  statements     = [local.cluster_kms_policy_statement]

  count          = var.use_cluster_encryption == true && var.create_policies == true ? 1 : 0

}

resource "oci_identity_policy" "oke_volume_kms" {
  provider       = oci.home
  compartment_id = var.compartment_id
  description    = "Policies for block volumes to access kms key"
  name           = var.label_prefix == "none" ? "oke-volume-kms" : "${var.label_prefix}-oke-volume-kms"
  statements     = local.oke_volume_kms_policy_statements

  count          = var.use_node_pool_volume_encryption == true && var.create_policies == true ? 1 : 0

}
