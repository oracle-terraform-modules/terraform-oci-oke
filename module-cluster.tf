# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Used to retrieve cluster CA certificate or configure local kube context

data "oci_containerengine_clusters" "existing_cluster" {
  count          = var.cluster_id != null ? 1 : 0
  compartment_id = local.compartment_id

  state = ["ACTIVE", "UPDATING"]
  filter {
    name   = "id"
    values = [var.cluster_id]
  }
}

data "oci_containerengine_cluster_kube_config" "public" {
  count = local.cluster_enabled && local.public_endpoint_available ? 1 : 0

  cluster_id = local.cluster_id
  endpoint   = "PUBLIC_ENDPOINT"
}

data "oci_containerengine_cluster_kube_config" "private" {
  count = local.cluster_enabled && local.private_endpoint_available ? 1 : 0

  cluster_id = local.cluster_id
  endpoint   = "PRIVATE_ENDPOINT"
}

locals {
  cluster_enabled = var.create_cluster || coalesce(var.cluster_id, "none") != "none"
  cluster_id      = var.create_cluster ? one(module.cluster[*].cluster_id) : var.cluster_id
  cluster_name    = var.cluster_name

  cluster-context = try(format("context-%s", substr(local.cluster_id, -11, -1)), "")

  existing_cluster_endpoints = coalesce(one(flatten(data.oci_containerengine_clusters.existing_cluster[*].clusters[*].endpoints)), tomap({}))
  public_endpoint_available  = var.cluster_id != null ? length(lookup(local.existing_cluster_endpoints, "public_endpoint", "")) > 0 : var.control_plane_is_public && var.assign_public_ip_to_control_plane
  private_endpoint_available = var.cluster_id != null ? length(lookup(local.existing_cluster_endpoints, "private_endpoint", "")) > 0 : true
  kubeconfig_public          = var.control_plane_is_public ? try(yamldecode(replace(lookup(one(data.oci_containerengine_cluster_kube_config.public), "content", ""), local.cluster-context, var.cluster_name)), tomap({})) : null
  kubeconfig_private         = try(yamldecode(replace(lookup(one(data.oci_containerengine_cluster_kube_config.private), "content", ""), local.cluster-context, var.cluster_name)), tomap({}))

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
  vcn_id                            = local.vcn_id
  cni_type                          = var.cni_type
  control_plane_is_public           = var.control_plane_is_public
  enable_ipv6                       = var.enable_ipv6
  assign_public_ip_to_control_plane = var.assign_public_ip_to_control_plane
  control_plane_nsg_ids             = compact(flatten([var.control_plane_nsg_ids, try(module.network.control_plane_nsg_id, null)]))
  control_plane_subnet_id           = try(module.network.control_plane_subnet_id, "") # safe destroy; validated in submodule
  pods_cidr                         = var.pods_cidr
  services_cidr                     = var.services_cidr
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
  cluster_defined_tags = merge(
    var.use_defined_tags ? {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "cluster",
    } : {},
    local.cluster_defined_tags,
  )
  cluster_freeform_tags = merge(
    var.use_defined_tags ? {} : {
      "state_id" = local.state_id,
      "role"     = "cluster",
    },
    local.cluster_freeform_tags,
  )
  persistent_volume_defined_tags = merge(
    var.use_defined_tags ? {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "persistent_volume",
    } : {},
    local.persistent_volume_defined_tags,
  )
  persistent_volume_freeform_tags = merge(
    var.use_defined_tags ? {} : {
      "state_id" = local.state_id,
      "role"     = "persistent_volume",
    },
    local.persistent_volume_freeform_tags,
  )
  service_lb_defined_tags = merge(
    var.use_defined_tags ? {
      "${var.tag_namespace}.state_id" = local.state_id,
      "${var.tag_namespace}.role"     = "service_lb"
    } : {},
    local.service_lb_defined_tags,
  )
  service_lb_freeform_tags = merge(
    var.use_defined_tags ? {} : {
      "state_id" = local.state_id,
      "role"     = "service_lb"
    },
    local.service_lb_freeform_tags,
  )

  oidc_discovery_enabled           = var.oidc_discovery_enabled
  oidc_token_auth_enabled          = var.oidc_token_auth_enabled
  oidc_token_authentication_config = var.oidc_token_authentication_config

  depends_on = [
    module.iam_cluster_prerequisites,
  ]
}

output "cluster_id" {
  description = "ID of the OKE cluster"
  value       = one(module.cluster[*].cluster_id)
}

output "cluster_endpoints" {
  description = "Endpoints for the OKE cluster"
  value       = var.create_cluster ? one(module.cluster[*].endpoints) : local.existing_cluster_endpoints
}

output "cluster_oidc_discovery_endpoint" {
  description = "OIDC discovery endpoint for the OKE cluster"
  value       = var.create_cluster && var.oidc_discovery_enabled ? one(module.cluster[*].oidc_discovery_endpoint) : null
}

output "cluster_kubeconfig" {
  description = "OKE kubeconfig"
  value = var.output_detail ? (
    local.public_endpoint_available ? local.kubeconfig_public : local.kubeconfig_private
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
