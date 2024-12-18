# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

cluster_addons = {
  "CertManager" = {
    remove_addon_resources_on_delete = true
    override_existing = true           # Default is false if not specified
    # The list of supported configurations for the cluster addons is here: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons-configurationarguments.htm#contengconfiguringclusteraddons-configurationarguments_CertificateManager
    configurations = [
      {
        key          = "numOfReplicas"
        value        = "1"
      }
    ]
  }
}

cluster_addons_to_remove = {
  Flannel = {
    remove_k8s_resources = true
  }
}