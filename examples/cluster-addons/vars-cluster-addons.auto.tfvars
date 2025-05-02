# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

cluster_addons = {
  "CertManager" = {
    remove_addon_resources_on_delete = true
    override_existing                = true # Default is false if not specified
    # The list of supported configurations for the cluster addons is here: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons-configurationarguments.htm#contengconfiguringclusteraddons-configurationarguments_CertificateManager
    configurations = [
      {
        key   = "numOfReplicas"
        value = "1"
      }
    ]
  }
  # The NvidiaGpuPlugin is disabled by default. To enable it, add the following block to the cluster_addons variable
  "NvidiaGpuPlugin" = {
    remove_addon_resources_on_delete = true
  },
  # Prevent Flannel pods from being scheduled using a non-existing label as nodeSelector
  "Flannel" = {
    remove_addon_resources_on_delete = true
    override_existing                = true # Override the existing configuration with this one, if Flannel addon in already enabled
    configurations = [
      {
        key   = "nodeSelectors"
        value = "{\"addon\":\"no-schedule\"}"
      }
    ],
  },
  # Prevent Kube-Proxy pods from being scheduled using a non-existing label as nodeSelector
  "KubeProxy" = {
    remove_addon_resources_on_delete = true
    override_existing                = true # Override the existing configuration with this one, if KubeProxy addon in already enabled
    configurations = [
      {
        key   = "nodeSelectors"
        value = "{\"addon\":\"no-schedule\"}"
      }
    ],
  }
}

cluster_addons_to_remove = {
  Flannel = {
    remove_k8s_resources = true
  }
}