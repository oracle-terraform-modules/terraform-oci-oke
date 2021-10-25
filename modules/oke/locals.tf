# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # used by cluster
  lb_subnet = var.preferred_load_balancer == "public" ? "pub_lb" : "int_lb"

  ad_names = [
    for ad_name in data.oci_identity_availability_domains.ad_list.availability_domains :
    ad_name.name
  ]

  # dynamic group all oke clusters in a compartment
  dynamic_group_rule_all_clusters = "ALL {resource.type = 'cluster', resource.compartment.id = '${var.compartment_id}'}"

  # policy to allow dynamic group of all clusters to use kms 
  policy_statement = (var.use_encryption == true) ? "Allow dynamic-group ${oci_identity_dynamic_group.oke_kms_cluster[0].name} to use keys in compartment id ${var.compartment_id} where target.key.id = '${var.kms_key_id}'" : ""

  # 1. get a list of available images for this cluster
  # 2. filter by version
  # 3. if more than 1 image found for this version, pick the latest
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_options.sources

}
