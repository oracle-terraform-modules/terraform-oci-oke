# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# All configuration for extensions sub-module w/ defaults

# Container Registry (OCIR)
email_address    = ""
secret_id        = "none"
secret_name      = "ocirsecret"
secret_namespace = "default"
username         = ""

# Calico
enable_calico  = false # true/*false
calico_version = "3.19"

# Pod autoscaling
enable_metric_server = false # true/*false
enable_vpa           = false # true/*false
vpa_version          = 0.8

# OPA Gatekeeper
enable_gatekeeper  = false # true/*false
gatekeeper_version = "3.7"

# Service account
create_service_account               = false # true/*false
service_account_name                 = ""
service_account_namespace            = ""
service_account_cluster_role_binding = ""

deploy_cluster_autoscaler = false
