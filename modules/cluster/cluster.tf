# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kms_key_id         = coalesce(var.cluster_kms_key_id, "none") != "none" ? var.cluster_kms_key_id : null
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  type               = var.cluster_type
  defined_tags       = var.cluster_defined_tags
  freeform_tags      = var.cluster_freeform_tags
  vcn_id             = var.vcn_id

  cluster_pod_network_options {
    cni_type = var.cni_type == "flannel" ? "FLANNEL_OVERLAY" : "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = var.control_plane_is_public && var.assign_public_ip_to_control_plane
    nsg_ids              = var.control_plane_nsg_ids
    subnet_id            = var.control_plane_subnet_id
  }

  dynamic "image_policy_config" {
    for_each = var.use_signed_images ? [1] : []

    content {
      is_policy_enabled = true

      dynamic "key_details" {
        iterator = signing_keys_iterator
        for_each = var.image_signing_keys

        content {
          kms_key_id = signing_keys_iterator.value
        }
      }
    }
  }

  options {

    dynamic "open_id_connect_token_authentication_config" {
      for_each = var.oidc_token_auth_enabled ? [1] : []

      content {
        is_open_id_connect_auth_enabled = var.oidc_token_auth_enabled


        issuer_url         = lookup(var.oidc_token_authentication_config, "issuer_url", null)
        ca_certificate     = lookup(var.oidc_token_authentication_config, "ca_certificate", null)
        client_id          = lookup(var.oidc_token_authentication_config, "client_id", null)
        signing_algorithms = lookup(var.oidc_token_authentication_config, "signing_algorithms", null)

        groups_claim  = lookup(var.oidc_token_authentication_config, "groups_claim", null)
        groups_prefix = lookup(var.oidc_token_authentication_config, "groups_prefix", null)

        username_claim  = lookup(var.oidc_token_authentication_config, "username_claim", null)
        username_prefix = lookup(var.oidc_token_authentication_config, "username_prefix", null)

        dynamic "required_claims" {
          for_each = lookup(var.oidc_token_authentication_config, "required_claims", [])
          content {
            key   = lookup(required_claims.value, "key")
            value = lookup(required_claims.value, "value")
          }
        }
        configuration_file = lookup(var.oidc_token_authentication_config, "configuration_file", null)
      }
    }

    dynamic "open_id_connect_discovery" {
      for_each = var.oidc_discovery_enabled ? [1] : []
      content {
        is_open_id_connect_discovery_enabled = var.oidc_discovery_enabled
      }
    }



    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    persistent_volume_config {
      defined_tags  = var.persistent_volume_defined_tags
      freeform_tags = var.persistent_volume_freeform_tags
    }

    service_lb_config {
      defined_tags  = var.service_lb_defined_tags
      freeform_tags = var.service_lb_freeform_tags
    }

    service_lb_subnet_ids = compact([var.service_lb_subnet_id])
    ip_families           = var.enable_ipv6 ? ["IPv4", "IPv6"] : ["IPv4"]
  }

  timeouts {
    update = "120m"
  }

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags, cluster_pod_network_options, options[0].kubernetes_network_config]

    precondition {
      condition     = var.service_lb_subnet_id != null
      error_message = "Missing service load balancer subnet."
    }

    precondition {
      condition     = !var.use_signed_images || length(var.image_signing_keys) > 0
      error_message = "Must provide at least 1 image signing key when use_signed_images is enabled."
    }

    precondition {
      condition     = var.service_lb_subnet_id != null
      error_message = <<-EOT
      Must have a service load balancer subnet ID for the preferred load balancer type.
        control_plane_is_public: ${coalesce(var.control_plane_is_public, "none")}
        service_lb_subnet_id: ${coalesce(var.service_lb_subnet_id, "none")}
      EOT
    }
  }
}
