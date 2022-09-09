# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  # used by cluster
  lb_subnet = var.preferred_load_balancer == "public" ? "pub_lb" : "int_lb"

  ad_number_to_name = {
    for ad in data.oci_identity_availability_domains.ad_list.availability_domains :
    parseint(substr(ad.name, -1, -1), 10) => ad.name
  }
  ad_numbers = keys(local.ad_number_to_name)

  # dynamic group all oke clusters in a compartment
  dynamic_group_rule_all_clusters = "ALL {resource.type = 'cluster', resource.compartment.id = '${var.compartment_id}'}"

  # policy to allow dynamic group of all clusters to use kms 
  cluster_kms_policy_statement = (var.use_cluster_encryption == true && var.create_policies) ? "Allow dynamic-group ${oci_identity_dynamic_group.oke_kms_cluster[0].name} to use keys in compartment id ${var.compartment_id} where target.key.id = '${var.cluster_kms_key_id}'" : ""

  # policy to allow block volumes inside oke to use kms
  oke_volume_kms_policy_statements = (var.use_node_pool_volume_encryption == true && var.create_policies) ? [
    "Allow service oke to use key-delegates in compartment id ${var.compartment_id} where target.key.id = '${var.node_pool_volume_kms_key_id}'",
    "Allow service blockstorage to use keys in compartment id ${var.compartment_id} where target.key.id = '${var.node_pool_volume_kms_key_id}'"
  ] : []

  # 1. get a list of available images for this cluster
  # 2. filter by version
  # 3. if more than 1 image found for this version, pick the latest
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_options.sources

  # kubernetes string version length
  k8s_version_length = length(var.cluster_kubernetes_version)
  k8s_version_only = substr(var.cluster_kubernetes_version,1,local.k8s_version_length)

}
