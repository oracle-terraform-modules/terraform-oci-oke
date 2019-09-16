# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  # used by cluster
  lb_subnet = var.lbs.preferred_lb_subnets == "public" ? "pub_lb" : "int_lb"

  # used by datasources
  available_kubernetes_versions = data.oci_containerengine_cluster_option.k8s_cluster_option.kubernetes_versions
  num_kubernetes_versions       = length(local.available_kubernetes_versions)
  kubernetes_version            = var.oke_cluster.cluster_kubernetes_version == "LATEST" ? element(sort(local.available_kubernetes_versions), (local.num_kubernetes_versions - 1)) : var.oke_cluster.cluster_kubernetes_version
}

