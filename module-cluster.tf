# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Used to retrieve cluster CA certificate or configure local kube context
data "oci_containerengine_cluster_kube_config" "public" {
  count      = local.cluster_enabled && var.control_plane_is_public ? 1 : 0
  cluster_id = local.cluster_id
  endpoint   = "PUBLIC_ENDPOINT"
}

data "oci_containerengine_cluster_kube_config" "private" {
  count      = local.cluster_enabled ? 1 : 0
  cluster_id = local.cluster_id
  endpoint   = "PRIVATE_ENDPOINT"
}

locals {
  cluster_enabled = var.create_cluster || coalesce(var.cluster_id, "none") != "none"
  cluster_id      = var.create_cluster ? one(module.cluster[*].cluster_id) : var.cluster_id
  cluster_name    = coalesce(var.cluster_name, "oke-${local.state_id}")

  kubeconfig_public  = var.control_plane_is_public ? try(yamldecode(lookup(one(data.oci_containerengine_cluster_kube_config.public), "content", "")), tomap({})) : null
  kubeconfig_private = try(yamldecode(lookup(one(data.oci_containerengine_cluster_kube_config.private), "content", "")), tomap({}))

  kubeconfig_clusters = try(lookup(local.kubeconfig_private, "clusters", []), [])
  apiserver_private_host = (var.create_cluster
    ? try(split(":", one(module.cluster[*].endpoints.private_endpoint))[0], "")
  : split(":", replace(try(lookup(lookup(local.kubeconfig_clusters[0], "cluster", {}), "server", ""), "none"), "https://", ""))[0])

  kubeconfig_ca_cert = try(lookup(lookup(local.kubeconfig_clusters[0], "cluster", {}), "certificate-authority-data", ""), "none")
  cluster_ca_cert    = coalesce(var.cluster_ca_cert, local.kubeconfig_ca_cert)
}

module "cluster" {
  count          = var.create_cluster ? 1 : 0
  source         = "./modules/cluster"
  compartment_id = local.compartment_id
  state_id       = local.state_id

  # Network
  vcn_id                  = local.vcn_id
  cni_type                = var.cni_type
  control_plane_is_public = var.control_plane_is_public
  control_plane_nsg_ids   = compact(flatten([var.control_plane_nsg_ids, try(module.network.control_plane_nsg_id, null)]))
  control_plane_subnet_id = try(module.network.control_plane_subnet_id, "") # safe destroy; validated in submodule
  pods_cidr               = var.pods_cidr
  services_cidr           = var.services_cidr
  service_lb_subnet_id = (var.preferred_load_balancer == "public"
    ? try(module.network.pub_lb_subnet_id, "") # safe destroy; validated in submodule
    : try(module.network.int_lb_subnet_id, "")
  )

  # Cluster
  cluster_kms_key_id = var.cluster_kms_key_id
  cluster_name       = local.cluster_name
  cluster_type = lookup({
    "basic"    = "BASIC_CLUSTER",
    "enhanced" = "ENHANCED_CLUSTER"
  }, lower(var.cluster_type), "BASIC_CLUSTER")
  kubernetes_version = var.kubernetes_version

  # KMS
  use_signed_images  = var.use_signed_images
  image_signing_keys = var.image_signing_keys

  # Tags
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

  # Standard tags as defined if enabled for use, or freeform
  # User-provided tags are merged last and take precedence
  cluster_defined_tags = var.use_defined_tags ? merge(
    {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "cluster",
    },
    local.cluster_defined_tags,
  ) : {}
  cluster_freeform_tags = var.use_defined_tags ? {} : merge(
    {
      "state_id" = local.state_id,
      "role"     = "cluster",
    },
    local.cluster_freeform_tags,
  )
  persistent_volume_defined_tags = var.use_defined_tags ? merge(
    {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "persistent_volume",
    },
    local.persistent_volume_defined_tags,
  ) : {}
  persistent_volume_freeform_tags = var.use_defined_tags ? {} : merge(
    {
      "state_id" = local.state_id,
      "role"     = "persistent_volume",
    },
    local.persistent_volume_freeform_tags,
  )
  service_lb_defined_tags = var.use_defined_tags ? merge(
    {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "service_lb"
    },
    local.service_lb_defined_tags,
  ) : {}
  service_lb_freeform_tags = var.use_defined_tags ? {} : merge(
    {
      "state_id" = local.state_id,
      "role"     = "service_lb"
    },
    local.service_lb_freeform_tags,
  )

  providers = {
    oci.home = oci.home
  }
}

output "cluster_id" {
  description = "ID of the OKE cluster"
  value       = one(module.cluster[*].cluster_id)
}

output "cluster_endpoints" {
  description = "Endpoints for the OKE cluster"
  value       = var.create_cluster ? one(module.cluster[*].endpoints) : null
}

output "cluster_kubeconfig" {
  description = "OKE kubeconfig"
  value = var.output_detail ? (
    var.control_plane_is_public ? local.kubeconfig_public : local.kubeconfig_private
  ) : null
}

output "cluster_ca_cert" {
  description = "OKE cluster CA certificate"
  value       = var.output_detail && length(local.cluster_ca_cert) > 0 ? local.cluster_ca_cert : null
}

output "apiserver_private_host" {
  description = "Private OKE cluster endpoint address"
  value       = local.apiserver_private_host
}
