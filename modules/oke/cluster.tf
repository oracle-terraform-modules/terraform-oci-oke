# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  kubernetes_versions = "${length(data.oci_containerengine_cluster_option.k8s_cluster_option.kubernetes_versions)}"
}

data "oci_containerengine_cluster_option" "k8s_cluster_option" {
  #Required
  cluster_option_id = "all"
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.cluster_kubernetes_version == "LATEST" ? element(sort(data.oci_containerengine_cluster_option.k8s_cluster_option.kubernetes_versions), local.kubernetes_versions - 1): var.cluster_kubernetes_version}"
  name               = "${var.label_prefix}-${var.cluster_name}"

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = "${var.cluster_options_add_ons_is_kubernetes_dashboard_enabled}"
      is_tiller_enabled               = "${var.cluster_options_add_ons_is_tiller_enabled}"
    }

    kubernetes_network_config {
      pods_cidr     = "${var.cluster_options_kubernetes_network_config_pods_cidr}"
      services_cidr = "${var.cluster_options_kubernetes_network_config_services_cidr}"
    }

    # Toggle between the 2 according to whether your region has 1 or 3 availability domains.
    # Verify here: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm how many domains your region has.


    # single ad regions
    #service_lb_subnet_ids = ["${var.cluster_subnets["lb_ad1"]}"]

    # multi ad regions
    service_lb_subnet_ids = ["${var.cluster_subnets["lb_ad1"]}", "${var.cluster_subnets["lb_ad2"]}"]
  }

  vcn_id = "${var.vcn_id}"
}