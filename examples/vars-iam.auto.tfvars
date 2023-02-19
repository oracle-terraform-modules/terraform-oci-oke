# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# All configuration for IAM sub-module w/ defaults

# General
config_file_profile = "DEFAULT"
tenancy_id          = "ocid1.tenancy..."     # required
compartment_id      = "ocid1.compartment..." # required
home_region         = "us-ashburn-1"         # required
region              = "us-ashburn-1"         # required

# Policies
create_iam_autoscaler_policy = "auto" # never/*auto/always
create_iam_kms_policy        = "auto" # never/*auto/always
create_iam_operator_policy   = "auto" # never/*auto/always
create_iam_worker_policy     = "auto" # never/*auto/always

# Defined tags
create_iam_tag_namespace = false # true/*false
create_iam_defined_tags  = false # true/*false
tag_namespace            = "oke"
use_defined_tags         = false # true/*false
