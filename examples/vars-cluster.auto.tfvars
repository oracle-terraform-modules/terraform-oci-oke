# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# All configuration for cluster sub-module w/ defaults

create_cluster     = true # *true/false
cluster_dns        = "10.96.5.5"
cluster_kms_key_id = null
cluster_name       = "oke"
cni_type           = "flannel"
control_plane_type = "public"
image_signing_keys = []
kubernetes_version = "v1.25.4"
pods_cidr          = "10.244.0.0/16"
services_cidr      = "10.96.0.0/16"
use_signed_images  = false # true/*false
