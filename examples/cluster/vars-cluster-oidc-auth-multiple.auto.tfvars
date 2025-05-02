# Copyright (c) 2017, 2025 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

create_cluster                    = true // *true/false
cluster_dns                       = null
cluster_kms_key_id                = null
cluster_name                      = "oke"
cluster_type                      = "enhanced" // *basic/enhanced
cni_type                          = "flannel"  // *flannel/npn
assign_public_ip_to_control_plane = true       // true/*false
image_signing_keys                = []
kubernetes_version                = "v1.32.1"
pods_cidr                         = "10.244.0.0/16"
services_cidr                     = "10.96.0.0/16"
use_signed_images                 = false // true/*false

# Enable OIDC token authentication for Github Actions using API server configuration file
open_id_connect_token_auth_enabled = true
open_id_connect_token_authentication_config = {
  configuration_file = base64encode(yamlencode(
    {
      "apiVersion" = "apiserver.config.k8s.io/v1beta1"
      "kind"       = "AuthenticationConfiguration"
      "jwt" = [
        {
          "issuer" = {
            "url" = "https://token.actions.githubusercontent.com",
            "audiences" = [
              "oke-kubernetes-cluster" # Must match the audience in the GitHub Actions workflow.
            ],
            "audienceMatchPolicy" = "MatchAny"
          }
          "claimMappings" = {
            "username" = {
              "claim"  = "sub"
              "prefix" = ""
            }
          }
          "claimValidationRules" = [
            {
              "claim"         = "repository"
              "requiredValue" = "GITHUB_ACCOUNT/GITHUB_REPOSITORY"
            },
            {
              "claim"         = "workflow"
              "requiredValue" = "oke-oidc" # Must match the workflow name.
            },
            {
              "claim"         = "ref"
              "requiredValue" = "refs/heads/main"
            },
          ]
        }
      ]
    }
  ))
}
