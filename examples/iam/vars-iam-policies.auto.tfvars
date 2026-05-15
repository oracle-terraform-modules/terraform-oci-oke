# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_iam_autoscaler_policy = "auto" // never/*auto/always
create_iam_kms_policy        = "auto" // never/*auto/always
create_iam_operator_policy   = "auto" // never/*auto/always
create_iam_worker_policy     = "auto" // never/*auto/always
create_iam_karpenter_policy  = "auto" // never/*auto/always

karpenter_optional_policies = {
  capacity_reservation     = false
  compute_clusters         = false
  cluster_placement_groups = false
  defined_tags             = false
}

karpenter_worker_compartments = []
