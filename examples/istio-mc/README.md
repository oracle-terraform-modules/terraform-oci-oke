# Multi-region service mesh with Istio and OKE

## Assumptions

1. A pair of OKE clusters in 2 different OCI regions will be used.
2. The OKE clusters will use private control planes.
3. The topology model used is [Multi-Primary on different networks](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/).

![Multi-primary on multiple networks](docs/assets/multi-primary%20multi-networks.png)
4. This example uses self-signed certificates.

## Create the OKE Clusters

1. Copy the terraform.tfvars.example to terraform.tfvars and provide the necessary values as detailed in steps 2-6.

2. Configure the provider parameters:

```
# provider
api_fingerprint = ""

api_private_key_path = "~/.oci/oci_rsa.pem"

home_region = "ashburn"

tenancy_id = "ocid1.tenancy.oc1.."

user_id = "ocid1.user.oc1.."

compartment_id = "ocid1.compartment.oc1.."
```

3. Configure an ssh key pair:

```
# ssh
ssh_private_key_path = "~/.ssh/id_rsa"
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
```

4. Configure your clusters' regions.

```
# clusters
clusters = {
  c1 = { region = "sydney", vcn = "10.1.0.0/16", pods = "10.201.0.0/16", services = "10.101.0.0/16", enabled = true }
  c2 = { region = "melbourne", vcn = "10.2.0.0/16", pods = "10.202.0.0/16", services = "10.102.0.0/16", enabled = true }
}
```

5. Configure additional parameters if necessary:

```
kubernetes_version = "v1.32.1"

cluster_type = "basic"

oke_control_plane = "private"
```

6. Configure your node pools:

```
nodepools = {
  np1 = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,
    memory           = 64,
    size             = 2,
    boot_volume_size = 150,
  }
}
```

7. Run terraform to create your clusters:

```
terraform apply --auto-approve
```

8. Once the Dynamic Routing Gateways (DRGs) and Remote Peering Connections (RPCs) have been created, use the OCI console to establish a connection between them.

## Install Istio

1. Terraform will output an ssh convenience command. Use it to ssh to the operator host:

```
ssh_to_operator = "ssh -o ProxyCommand='ssh -W %h:%p -i ~/.ssh/id_rsa opc@<bastion_ip>' -i ~/.ssh/id_rsa opc@<operator_ip>"
```

2. Verify connectivity to both clusters:

```
for cluster in c1 c2; do
  ktx $cluster
  k get nodes
done
```

3. Generate certs for each cluster:

```
export ISTIO_HOME=/home/opc/istio-1.20.2
cd $ISTIO_HOME/tools/certs 
make -f Makefile.selfsigned.mk c1-cacerts
make -f Makefile.selfsigned.mk c2-cacerts
```

4. Create and label istio-system namespace in each cluster:

```
for cluster in c1 c2; do
  ktx $cluster
  k create ns istio-system
  k label namespace istio-system topology.istio.io/network=$cluster
done
```

5. Create a secret containing the certificates in istio-system namespace for both clusters:

```
for cluster in c1 c2; do
  ktx $cluster
  kubectl create secret generic cacerts -n istio-system \
      --from-file=$cluster/ca-cert.pem \
      --from-file=$cluster/ca-key.pem \
      --from-file=$cluster/root-cert.pem \
      --from-file=$cluster/cert-chain.pem
done
```

6. Install Istio in both clusters:

```
for cluster in c1 c2; do
  ktx $cluster
  istioctl install --set profile=default -f $HOME/$cluster.yaml
done
```

7. Verify the Istio installation in both clusters:

```
for cluster in c1 c2; do
  ktx $cluster
  istioctl verify-install
done
```

8. Check if the load balancers have been properly provisioned:

```
for cluster in c1 c2; do
  ktx $cluster
  k -n istio-system get svc
done
```

9. Check if Istio pods are running:

```
for cluster in c1 c2; do
  ktx $cluster
  k -n istio-system get pods
done
```

10. Create an Gateway to expose all services through the eastwest ingress gateway:

```
cd $ISTIO_HOME
for cluster in c1 c2; do
  ktx $cluster
  k apply -f samples/multicluster/expose-services.yaml
done
```

11. Set the environment variables to verify multi-cluster connectivity:
```
export CTX_CLUSTER1=c1
export CTX_CLUSTER2=c2
```

12. Enable endpoint discovery in each cluster by creating a remote secret:

```
istioctl create-remote-secret \
  --context="${CTX_CLUSTER1}" \
  --name="${CTX_CLUSTER1}" | \
  kubectl apply -f - --context="${CTX_CLUSTER2}"


 istioctl create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --name="${CTX_CLUSTER2}" | \
  kubectl apply -f - --context="${CTX_CLUSTER1}"
```

## Verify cross-cluster connectivity

1. Deploy the HelloWorld Service in both clusters:

```
for cluster in c1 c2; do
  kubectl create --context="${cluster}" namespace sample
  kubectl label --context="${cluster}" namespace sample istio-injection=enabled
  kubectl apply --context="${cluster}" -f samples/helloworld/helloworld.yaml -l service=helloworld -n sample
done
```

2. Deploy v1 to cluster c1:

```
kubectl apply --context="${CTX_CLUSTER1}" \
    -f samples/helloworld/helloworld.yaml \
    -l version=v1 -n sample

kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l app=helloworld
```

3. Deploy v2 to cluster c2:

```
kubectl apply --context="${CTX_CLUSTER2}" \
    -f samples/helloworld/helloworld.yaml \
    -l version=v2 -n sample

kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l app=helloworld
```

4. Deploy Sleep client pod in both clusters:

```
kubectl apply --context="${CTX_CLUSTER1}" \
    -f samples/sleep/sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f samples/sleep/sleep.yaml -n sample
```

5. Generate traffic from c1. The response should alternate between c1 (v1) and c2 (v2) regions:

```
for i in $(seq 1 100); do
kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
done
```

6. Generate traffic from c2. The response should alternate between c1 (v1) and c2 (v2) regions:

```
for i in $(seq 1 100); do
kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
done
```

7. Cross-cluster connectivity has been verified.

