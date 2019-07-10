# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  lb_ads = var.preferred_lb_type == "public" ? list(format("pub_lb_%s", element(var.preferred_lb_ads, 0)), format("pub_lb_%s", element(var.preferred_lb_ads, 1))) : list(format("int_lb_%s", element(var.preferred_lb_ads, 0)), format("int_lb_%s", element(var.preferred_lb_ads, 1)))
}
resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = local.kubernetes_version
  name               = "${var.label_prefix}-${var.cluster_name}"

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = var.cluster_options_add_ons_is_tiller_enabled
    }

    kubernetes_network_config {
      pods_cidr     = var.cluster_options_kubernetes_network_config_pods_cidr
      services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
    }

    service_lb_subnet_ids = length(var.ad_names) == 1 ? [var.cluster_subnets[element(local.lb_ads, 0)]] : [var.cluster_subnets[element(local.lb_ads, 0)], var.cluster_subnets[element(local.lb_ads, 1)]]
  }

  vcn_id = var.vcn_id
}
