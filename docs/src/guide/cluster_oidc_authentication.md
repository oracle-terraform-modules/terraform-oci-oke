# OpenID Connect Authentication

By default, OKE clusters are set up to authenticate individuals (human users, groups or service principals) accessing the API endpoint using OCI Identity and Access Management (IAM). 

Using OKE OIDC Authentication, we can authenticate OKE API Endpoint requests (from human users or service principals) using tokens issued by third-party Identity Providers without the need for federation with OCI IAM.

## Prerequisites

Note the following prerequisites for enabling a cluster for OIDC authentication:

- The cluster must be an enhanced cluster. OIDC authentication is not supported for basic clusters.
- The cluster must be running Kubernetes version 1.21 (or later) -- for single external OIDC IdP setup.
- The cluster must be running Kubernetes version 1.30 (or later) -- for multiple external OIDC IdPs setup.

## Configuration

In addition to the implicit OCI IAM, you can configure the OKE cluster to authenticate the cluster API endpoint requests using a **single** external OIDC (OpenID Connect) Identity Provider (IdP).

For this is necessary to set the following variables:

```
oidc_discovery_enabled = true
oidc_token_authentication_config = {
  client_id          = ...,
  issuer_url         = ...,
  username_claim     = ...,
  username_prefix    = ...,
  groups_claim       = ...,
  groups_prefix      = ...,
  required_claims    = [
    {
      key = ...,
      value = ...
    },
    {
      key = ...,
      value = ...
    }
  ],
  ca_certificate     = ...,
  signing_algorithms = []
}
```

In case you're looking to authenticate the cluster API endpoint requests with **multiple** OIDC IdPs, you can take advantage of the [authentication configuration via file Kubernetes feature](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-authentication-configuration).

```
oidc_discovery_enabled = true
oidc_token_authentication_config = {
  configuration_file = base64encode(yamlencode(
    {
      "apiVersion" = "apiserver.config.k8s.io/v1beta1"
      "kind"       = "AuthenticationConfiguration"
      "jwt"        = [
        {
          "issuer"= {
            "url"       = "...",
            "audiences" = [
              "..."
            ],
            "audienceMatchPolicy" = "MatchAny"
          }
          "claimMappings" = {
            "username" = {
              "claim" = "..."
              "prefix" = ""
            }
          }
          "claimValidationRules" = [
            {
              "claim" = "..."
              "requiredValue" = "..."
            }
          ]
        }
      ]
    }
  ))
}
```

The authenticated users are mapped to a `User` resource in Kubernetes and you have to setup the desired RBAC polices to provide access.

E.g. for Github Action workflow:

```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: actions-oidc-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "watch", "list", "create", "update", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: actions-oidc-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: actions-oidc-role
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: actions-oidc:repo:GH-ACCOUNT/GH-REPO:ref:refs/heads/main
```

**Note:** 
1. You need to make sure the OKE Control Plane endpoint is allowed to connect to the IdP.

```
allow_rules_cp = {
  "Allow egress to anywhere HTTPS from OKE CP" : {
    protocol = "6", port=443, destination = "0.0.0.0/0", destination_type = "CIDR_BLOCK",
  }
}
```
2. You cannot configure cluster OIDC Authentication using the arguments of the `oidc_token_authentication_config` (`client_id`, `issuer_url`, etc..) **and** the `configuration_file` at the same time.

## OpenID Connect Discovery

### Prerequisites

Note the following points when using OIDC Discovery:

- The cluster must be an enhanced cluster. OIDC Discovery is not supported for basic clusters.
- The cluster must be running Kubernetes version 1.21 (or later).

### Configuration

OKE already supports Workload Identity to enable Kubernetes pods to access OCI resources, such as a secret or cloud storage bucket without storing access credentials in your Kubernetes cluster.

If you are looking to authorize Kubernetes pods to access non-OCI resources you can enable OKE OIDC Discovery.

When you enable OIDC discovery for an OKE cluster, OKE provides an OpenID Connect issuer endpoint. This endpoint serves the OIDC discovery document and the JSON web key set (JWKS), which contain the public key necessary for token validation. These resources enable third-party IdP to validate tokens issued for pods in the OKE cluster, allowing those pods to access non-OCI resources.

[ ![](../images/oidc-discovery.png) ](../images/oidc-discovery.png)
*Figure 1: OIDC Discovery*

To enable the OKE OIDC Discovery, you have to set the following variable:

```
open_id_connect_discovery_enabled = true
```

The OpenID Connect issuer endpoint is available in the output:

```
cluster_oidc_discovery_endpoint
```

## Example usage

OIDC Authentication setup using Kubernetes API server flags

```javascript
{{#include ../../../examples/cluster-addons/vars-cluster-oidc-auth-single.auto.tfvars:4:}}
```

OIDC Authentication setup using Kubernetes API server configuration file

```javascript
{{#include ../../../examples/cluster-addons/vars-cluster-oidc-auth-multiple.auto.tfvars:4:}}
```

## Reference
* [OKE OpenID Authetication](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengOpenIDConnect-Authentication.htm)
* [OKE Cluster Terraform resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)
* [Github workflow OKE OIDC authentication](https://docs.oracle.com/en/learn/gaw-oke-odic/index.html#introduction)
* [Kubernetes OIDC Authentication setup using Kubernetes API server configuration file](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-authentication-configuration)
* [Kubernetes OIDC Authentication setup using Kubernetes API server flags](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#using-flags)
