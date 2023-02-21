# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Used to retrieve cluster CA certificate or configure local kube context
data "oci_containerengine_cluster_kube_config" "public" {
  count      = var.create_cluster || coalesce(var.cluster_id, "none") != "none" ? 1 : 0
  cluster_id = local.cluster_id
  endpoint   = "PUBLIC_ENDPOINT"
}

data "oci_containerengine_cluster_kube_config" "private" {
  count      = var.create_cluster || coalesce(var.cluster_id, "none") != "none" ? 1 : 0
  cluster_id = local.cluster_id
  endpoint   = "PRIVATE_ENDPOINT"
}

locals {
  cluster_id          = var.create_cluster ? one(module.cluster[*].cluster_id) : var.cluster_id
  kubeconfig_public   = try(yamldecode(lookup(one(data.oci_containerengine_cluster_kube_config.public), "content", "")), { "error" : "yamldecode" })
  kubeconfig_private  = try(yamldecode(lookup(one(data.oci_containerengine_cluster_kube_config.private), "content", "")), { "error" : "yamldecode" })
  kubeconfig_clusters = try(lookup(local.kubeconfig_private, "clusters", []), [])
  kubeconfig_ca_cert  = try(lookup(lookup(local.kubeconfig_clusters[0], "cluster", {}), "certificate-authority-data", ""), "none")
  cluster_ca_cert     = coalesce(var.cluster_ca_cert, local.kubeconfig_ca_cert)
}

module "cluster" {
  count          = var.create_cluster ? 1 : 0
  source         = "./modules/cluster"
  compartment_id = local.compartment_id
  state_id       = random_id.state_id.id

  # Network
  cni_type                = var.cni_type
  control_plane_nsg_ids   = setunion(var.control_plane_nsg_ids, var.create_nsgs ? [module.network.cp_nsg_id] : [])
  control_plane_subnet_id = lookup(module.network.subnet_ids, "cp")
  control_plane_type      = var.control_plane_type
  pods_cidr               = var.pods_cidr
  service_lb_subnet_id    = lookup(module.network.subnet_ids, var.preferred_load_balancer == "public" ? "pub_lb" : "int_lb")
  services_cidr           = var.services_cidr
  vcn_id                  = local.vcn_id

  # Cluster
  cluster_kms_key_id = var.cluster_kms_key_id
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # KMS
  use_signed_images  = var.use_signed_images
  image_signing_keys = var.image_signing_keys

  # Tags
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace
  defined_tags     = lookup(var.defined_tags, "cluster", {})
  freeform_tags    = lookup(var.freeform_tags, "cluster", {})

  providers = {
    oci.home = oci.home
  }
}

output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = one(module.cluster[*].cluster_id)
}

output "cluster_endpoints" {
  description = "Endpoints for the Kubernetes cluster"
  value       = var.create_cluster ? one(module.cluster[*].endpoints) : null
}

output "cluster_kubeconfig" {
  description = "OKE kubeconfig"
  value = var.output_detail ? (
    var.control_plane_type == "public" ? local.kubeconfig_public : local.kubeconfig_private
  ) : null
}

output "cluster_ca_cert" {
  description = "OKE cluster CA certificate"
  value       = var.output_detail && length(local.cluster_ca_cert) > 0 ? local.cluster_ca_cert : null
}
