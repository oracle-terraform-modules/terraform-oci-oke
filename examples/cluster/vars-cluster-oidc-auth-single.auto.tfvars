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

# Enable OIDC token authentication for Github Actions using API server flags
oidc_token_auth_enabled = true
oidc_token_authentication_config = {
  client_id      = "oke-kubernetes-cluster" # Must match the audience in the GitHub Actions workflow.
  issuer_url     = "https://token.actions.githubusercontent.com",
  username_claim = "sub"
  required_claims = [
    {
      key   = "repository",
      value = "GITHUB_ACCOUNT/GITHUB_REPOSITORY"
    },
    {
      key   = "workflow",
      value = "oke-oidc" # Must match the workflow name.
    },
    {
      key   = "ref"
      value = "refs/heads/main"
    }
  ],
}

