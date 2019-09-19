# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  
  dynamic_group_rule_all_clusters = "ALL {resource.type = 'cluster', resource.compartment.id = '${var.oci_identity.compartment_ocid}'}"
  
  dynamic_group_rule_this_cluster = "ALL {resource.type = 'cluster', resource.id = '${var.cluster_id}'}"

  policy_statement = "Allow dynamic-group ${oci_identity_dynamic_group.oke-kms-cluster[0].name} to use keys in compartment ${var.oci_identity.compartment_name} where target.key.id = '${var.oke_kms.key_id}'"

}