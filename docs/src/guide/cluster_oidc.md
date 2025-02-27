# Cluster OIDC

OKE provides OpenID Connect Authentication and Discovery.

## OpenID Connect Authentication

The OKE clusters are configured by default to authenticate the users using OCI Identity and Access Management.

In addition to OCI IAM, you can configure the OKE cluster to authenticate the users using an external OIDC (OpenID Connect) IdP (Identity Provider).

For this is necessary to set the following variables:

```
open_id_connect_discovery_enabled = true
open_id_connect_token_authentication_config = {
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
You need to make sure the OKE Control Plane endpoint is allowed to connect to the IdP.

```
allow_rules_cp = {
  "Allow egress to anywhere HTTPS from OKE CP" : {
    protocol = "6", port=443, destination = "0.0.0.0/0", destination_type = "CIDR_BLOCK",
  }
}
```

## OpenID Connect Discovery

OKE already supports Workload Identity to enable Kubernetes pods to access OCI resources, such as a secret or cloud storage bucket without storing access credentials in your Kubernetes cluster.

If you are looking to authorize Kubernetes pods to access non-OCI resources you can enable OKE OIDC Discovery.

When you enable OIDC discovery for an OKE cluster, OKE provides an OpenID Connect issuer endpoint. This endpoint serves the OIDC discovery document and the JSON web key set (JWKS), which contain the public key necessary for token validation. These resources enable third-party IdP to validate tokens issued for pods in the OKE cluster, allowing those pods to access non-OCI resources.

To enable the OKE OIDC Discovery, you have to set the following variable:

```
open_id_connect_discovery_enabled = true
```

The OpenID Connect issuer endpoint is available in the output:
```
cluster_oidc_discovery_endpoint
```

## Example usage
```javascript
{{#include ../../../examples/cluster-addons/vars-cluster-oidc.auto.tfvars:4:}}
```

## Reference
* [OKE OpenID Authetication](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengOpenIDConnect-Authentication.htm)
* [OKE OpenID Discovery](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengOpenIDConnect-Discovery.htm)
* [OKE Cluster Terraform resource](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)
* [Github workflow OKE OIDC authentication](https://docs.oracle.com/en/learn/gaw-oke-odic/index.html#introduction)
* [OKE Pods access AWS resources](https://umashankar-s.medium.com/multicloud-use-case-oke-apps-pods-accessing-aws-resources-using-openid-disovery-8e147500656f)