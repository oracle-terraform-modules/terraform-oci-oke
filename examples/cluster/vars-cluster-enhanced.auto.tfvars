# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_cluster     = true // *true/false
cluster_dns        = null
cluster_kms_key_id = null
cluster_name       = "oke"
cluster_type       = "enhanced" // *basic/enhanced
cni_type           = "flannel"  // *flannel/npn
image_signing_keys = []
kubernetes_version = "v1.26.2"
pods_cidr          = "10.244.0.0/16"
services_cidr      = "10.96.0.0/16"
use_signed_images  = false // true/*false
