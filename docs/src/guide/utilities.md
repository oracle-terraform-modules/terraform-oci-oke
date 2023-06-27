# Utilities

## OCIR

**NOTE:** TODO Pending validation in 5.x

The [auth token]() must first be manually created and stored in [OCI Secret in Vault](). It will subsequently be used to create a Kubernetes secret, which can then be used as an `imagePullSecrets` in a deployment. If you do not need to use private OCIR repositories, then leave the `secret_id` parameter empty.

The secret is created in the "default" namespace. To copy it to your namespace, use the following command:

```shell
kubectl --namespace=default get secret ocirsecret --export -o yaml | kubectl apply --namespace=<newnamespace> -f -
```

### Creating a Secret

[Oracle Cloud Infrastructure Registry]() is a highly available private container registry service for storing and sharing container images within the same regions as the OKE Cluster. Use the following rules to determine if you need to create a Kubernetes Secret for OCIR:
* If your container repository is public, you do not need to create a secret.
* If your container repository is private, you need to create a secret before OKE can pull your images from the private repository.

If you plan on creating a Kubernetes Secret for OCIR, you must first [create an Auth Token](https://docs.cloud.oracle.com/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm). Copy and temporarily save the value of the Auth Token.

You must then [create a Secret in OCI Vault to store](https://docs.cloud.oracle.com/en-us/iaas/Content/KeyManagement/Tasks/managingsecrets.htm) the value of the Auth Token in it. 

Finally, assign the Secret OCID to `secret_id` in terraform.tfvars. Refer to {uri-terraform-options}#ocir[OCIR parameters] for other parameters to be set.

**NOTE:** Installing the Vertical Pod Autoscaler also requires installing the Metrics Server, so you need to enable that too.

### Service account

**NOTE:** TODO Pending validation in 5.x

OKE now uses Kubeconfig v2 which means the default token has a limited lifespan. In order to allow CI/CD tools to deploy to OKE, a service account must be created.

Set the *create_service_account = true* and you can name the other parameters as appropriate:
```properties
create_service_account = true
service_account_name = "kubeconfigsa"
service_account_namespace = "kube-system"
service_account_cluster_role_binding = ""
```

## KMS

The KMS integration parameters control whether [OCI Key Management Service]() will be used for encrypting Kubernetes secrets and boot volumes/block volumes. Additionally, the bastion and operator hosts must be enabled as well as instance_principal on the operator.

OKE also supports enforcing the use of signed images. You can enforce the use of signed image using the following parameters:
```properties
use_signed_images  = false
image_signing_keys = ["ocid1.key.oc1....", "ocid1.key.oc1...."]
```

[Reference]()
