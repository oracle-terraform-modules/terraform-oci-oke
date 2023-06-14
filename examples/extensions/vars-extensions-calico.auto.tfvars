# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

calico_install           = true
calico_version           = "3.24.1"
calico_mode              = "policy-only"
calico_mtu               = 0  // determined automatically by default
calico_url               = "" // determined automatically by default
calico_apiserver_install = false
calico_typha_install     = false
calico_typha_replicas    = 0
calico_staging_dir       = "/tmp/calico_install"
