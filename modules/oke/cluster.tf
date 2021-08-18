# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.cluster_kubernetes_version
  kms_key_id         = local.post_provisioning_ops == true && var.use_encryption == true ? var.kms_key_id : null
  name               = var.label_prefix == "none" ? var.cluster_name : "${var.label_prefix}-${var.cluster_name}"

  endpoint_config {
    is_public_ip_enabled = var.cluster_access == "public" ? true : false
    subnet_id            = var.cluster_subnets["cp"]
  }

  dynamic "image_policy_config" {
    for_each = var.use_signed_images == true ? [1] : []

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
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.admission_controller_options["PodSecurityPolicy"]
    }

    kubernetes_network_config {
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }

    service_lb_subnet_ids = var.preferred_lb_subnets == "public" ? [var.cluster_subnets["pub_lb"]] : [var.cluster_subnets["int_lb"]]
  }

  vcn_id = var.vcn_id
}
