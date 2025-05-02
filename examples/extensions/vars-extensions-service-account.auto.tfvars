# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_service_account = true
service_accounts = {
  # Example to create a cluster role binding using a cluster role.
  example_cluster_role_binding = {
    sa_name                 = "sa1"
    sa_namespace            = "kube-system"
    sa_cluster_role         = "cluster-admin"
    sa_cluster_role_binding = "sa1-crb"
  }
  # Example to create a role binding using a cluster role.
  example_role_binding = {
    sa_name         = "sa2"
    sa_namespace    = "default"
    sa_cluster_role = "cluster-admin"
    sa_role_binding = "sa1-rb"
  }
  # Example to create a role binding using a role, the role needs to exist within the namespace.
  example_role_binding = {
    sa_name         = "sa3"
    sa_namespace    = "kube-system"
    sa_role         = "system:controller:token-cleaner"
    sa_role_binding = "sa3-rb"
  }
}