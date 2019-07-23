# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  # used by cluster
  lb_ads = var.preferred_lb_subnets == "public" ? list(format("pub_lb_%s", element(var.preferred_lb_ads, 0)), format("pub_lb_%s", element(var.preferred_lb_ads, 1))) : list(format("int_lb_%s", element(var.preferred_lb_ads, 0)), format("int_lb_%s", element(var.preferred_lb_ads, 1)))
   
  # used by datasources
  available_kubernetes_versions = data.oci_containerengine_cluster_option.k8s_cluster_option.kubernetes_versions
  num_kubernetes_versions       = length(local.available_kubernetes_versions)
  kubernetes_version            = var.cluster_kubernetes_version == "LATEST" ? element(sort(local.available_kubernetes_versions), (local.num_kubernetes_versions - 1)) : var.cluster_kubernetes_version
}

