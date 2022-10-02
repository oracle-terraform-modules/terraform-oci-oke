# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# 30s delay to allow policies to take effect globally
resource "time_sleep" "wait_30_seconds" {
  depends_on = [oci_identity_policy.oke_kms]

  create_duration = "30s"
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.cluster_kubernetes_version
  kms_key_id         = var.use_cluster_encryption == true ? var.cluster_kms_key_id : null
  name               = var.label_prefix == "none" ? var.cluster_name : "${var.label_prefix}-${var.cluster_name}"
  
  depends_on = [time_sleep.wait_30_seconds]

  cluster_pod_network_options {
    cni_type = var.cni_type == "flannel" ? "FLANNEL_OVERLAY" : "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = var.control_plane_type == "public" ? true : false
    nsg_ids              = var.control_plane_nsgs
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

  freeform_tags = lookup(var.freeform_tags,"cluster",{})
  defined_tags  = lookup(var.defined_tags,"cluster",{})

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false
    }

    admission_controller_options {
      is_pod_security_policy_enabled = lookup(var.admission_controller_options,"PodSecurityPolicy",false)
    }

    kubernetes_network_config {
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }

    persistent_volume_config {
      freeform_tags = lookup(var.freeform_tags,"persistent_volume",{})
      defined_tags  = lookup(var.defined_tags,"persistent_volume",{})
    }

    service_lb_config {
      freeform_tags = lookup(var.freeform_tags,"service_lb",{})
      defined_tags  = lookup(var.defined_tags,"service_lb",{})
    }

    service_lb_subnet_ids = var.preferred_load_balancer == "public" ? [var.cluster_subnets["pub_lb"]] : [var.cluster_subnets["int_lb"]]
  }

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

  vcn_id = var.vcn_id

}
