# Instructions

[API signing]: https://docs.us-phoenix-1.oraclecloud.com/Content/API/Concepts/apisigningkey.htm
[calico]: https://www.projectcalico.org/
[cidrsubnet]:http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
[example network resource configuration]:https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengnetworkconfigexample.htm
[helm]:https://www.helm.sh/
[image ocids]:https://docs.cloud.oracle.com/iaas/images/oraclelinux-7x/
[kubernetes]: https://kubernetes.io/
[kubernetes dashboard]: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
[networks]:https://erikberg.com/notes/networks.html
[oci]: https://cloud.oracle.com/cloud-infrastructure
[oci console]: https://console.us-ashburn-1.oraclecloud.com/
[oke]: https://docs.us-phoenix-1.oraclecloud.com/Content/ContEng/Concepts/contengoverview.htm
[run on oci]:./run-on-oci.md
[terraform]: https://www.terraform.io
[terraform download]: https://www.terraform.io/downloads.html
[terraform options]: ./terraformoptions.md
[terraform oke sample]: https://github.com/oracle/terraform-provider-oci/tree/master/docs/examples/container_engine
[topology]: ./topology.md
[todo]: ./todo.md

## Install Terraform

1. [Download Terraform][terraform download]. You need version 0.11.11

2. Extract the terraform binary to a location in your path

    ```
    $ unzip terraform_0.11.11_linux_amd64.zip
    $ sudo cp terraform /usr/local/bin
    $ terraform -v
    Terraform v0.11.11
    ```

## Generate ssh keys

Generate an ssh key:

```
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/oracle/.ssh/id_rsa): /home/oracle/test/oci_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/oracle/test/oci_rsa.
Your public key has been saved in /home/oracle/test/oci_rsa.pub.
The key api_fingerprint is:
SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx oracle@redwood
```

> N.B. Replace 'oracle' above by your username

## Generate API keys

1. Create a .oci directory:

    ```
    $ mkdir ~/.oci
    ```

2. Generate the API private key

    ```
    $ openssl genrsa -out ~/.oci/oci_api_key.pem -aes128 2048
    ```

3. Ensure that only you can read the private key file:

    ```
    $ chmod go-rwx ~/.oci/oci_api_key.pem
    ```

4. Generate the public key:

    ```
    $ openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
    ```


## Configure your OCI account to use Terraform

1. Open the oci_api_key_public.pem file in a text editor and copy its content

2. Login to [OCI console][oci console]

3. Click on the username (top navigation) and select 'User Settings'

4. Under 'API Keys', Click on 'Add Public Key'

5. Paste the contents of the oci_api_key_public.pem file. Click 'Add'

6. You'll see the fingerprint of your ssh key. You'll copy this in the next section.

## OCI Policy Configuration for OKE

1. Select the **root** compartment of your tenancy

2. Navigate to Identity > Policies

3. Click 'Create Policy'

4. Add the following:

    1. Name: a unique name for the policy e.g. oke-creation-policy

    2. Description: A user friendly description

    3. Policy Versioning: Select 'Keep Policy Current'

    4. Policy Statements: add the following in the statement field: <br>
       ```
       allow service OKE to manage all-resources in tenancy
       ```   
    5. Click 'Create'

## Configure your environment to create the OKE cluster

1. Copy the terraform.tfvars.example file

    ```
    $ cp terraform.tfvars.example terraform.tfvars
    ```

2. Open the terraform.tfvars in a text editor e.g. vi, nano, emacs etc.

3. Copy the tenancy OCID from the OCI Console (Menu > Administration > Tenancy Details) and paste it in the tenancy_ocid field in terraform.tfvars e.g.:

    ```
    tenancy_ocid = "ocid1.tenancy.xx..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    ```

4. Under the 'User Information' tab, locate 'OCID' and click on 'Copy'. Paste it in the user_ocid field e.g.

    ```
    user_ocid = "ocid1.user.xx..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ```

5. Copy the compartment OCID from the OCI Console (Menu > Identity > Compartments) and paste it in the compartment_ocid field in terraform.tfvars e.g.:

    ```
    compartment_ocid = "ocid1.compartment.xx..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
    ```

6. Copy the fingerprint of your api key from the OCI Console and paste its value in the api_fingerprint field in terraform.tfvars e.g.

    ```
    api_fingerprint = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
    ```

7. Add the path to the following keys (based on example above):

    |   key   | path   |
    |   ----  | ----   |
    | api_private_key_path| ~/.oci/oci_api_key.pem |
    | ssh_private_key_path| /home/oracle/.ssh/id_rsa |
    | ssh_public_key_path | /home/oracle/.ssh/id_rsa.pub |


6. Set your region e.g.

    ```
    region = "us-ashburn-1"
    ```

7. Set the following environment variables:

    ```
    export http_proxy=http://proxy.server.com:port/
    export https_proxy=http://proxy.server.com:port/
    ```

> N.B. Replace the proxy.server.com:port with your proxy server address and port.

## Detailed Instructions for OKE

Review the [Terraform Configuration Parameters for OKE][terraform options]

### Bastion

The images and scripts used have been tested on Oracle Linux 7.x (latest: Oracle-Linux-7.5-2018.07.20-0). You can change the imageocids parameter if you wish to use an alternative version. You may also use this parameter to use your own custom image. Ensure you use either Oracle Linux or CentOS.

```
imageocids = {
    "us-phoenix-1"   = "ocid1.image.oc1.phx.aaaaaaaagtiusgjvzurghktkgphjuuky2q6qjwvsstzbhyn4czroszbjimvq"
    "us-ashburn-1"   = "ocid1.image.oc1.iad.aaaaaaaagqwnrno6c35vplndep6hu5gevyiqqag37muue3ich7g6tbs5aq4q"
    "eu-frankfurt-1" = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaat7npzgm7lquxd3k53krh7ffiwc6jv3ug5geu2pnq64djaxvpnh6q"
    "uk-london-1"    = "ocid1.image.oc1.uk-london-1.aaaaaaaasvgkftekukdo6325eu3tgvu2q54tct2zgezlzu2q6d26bemvf5fq"
}
```

> N.B. In a future release of this project, we will add ability to use Debian or Ubuntu for the bastion host.

#### oci-cli
oci-cli is preconfigured and upgraded for the opc user on the bastion instances. To use, enable 1 of the bastion instances in terraform.tfvars in the 'availability_domains' variable e.g.

```
availability_domains = {
    "bastion_ad1"     = "true"
}
```

You can do this any time i.e. either at the beginning or after the cluster has been created. After the instance is provisioned, terraform will output the ip address of the bastion instance(s):

```
ssh_to_bastion = [
    AD1: ssh opc@XXX.XXX.XXX.XXX,
    AD2: ssh opc@,
    AD3: ssh opc@
]
```

Copy the ssh command to the bastion instance to login and verify:

```
$ oci network vcn list --compartment-id <compartment-ocid>
```

You can turn off the bastion instance(s) anytime by setting the above value to false and run terraform apply again.

#### kubectl

kubectl is pre-installed on the bastion instances:

```
$ kubectl get nodes
```
#### ksonnet

ksonnet can be optionally installed on the bastion instances:

```
$ ks version
```

### OKE Networking
All subnets are programmable and can be controlled using the vcn_cidr, newbits and subnets variables. This can help you control the size and number of subnets that can be created within the VCNs e.g.
  
```
vcn_cidr = "10.0.0.0/16"

newbits = "8"

subnets = {
    "bastion_ad1"     = "11"        
    "bastion_ad2"     = "21"        
    "bastion_ad3"     = "31"        
    "lb_ad1"      = "12"        
    "lb_ad2"      = "22"        
    "lb_ad3"      = "32"        
    "workers_ad1" = "13"        
    "workers_ad2" = "23"        
    "workers_ad3" = "33"
}
```

OKE worker nodes can be configured in 2 modes:

- public
- private

In public mode, worker nodes will be created with public IP addresses and can accessed directly. NodePort Services can therefore be accessed directly.

In private mode, worker nodes will not have public IP addresses and can only be accessed through a bastion host. NodePort services can only be accessed through the bastion host or through a load balancer.

Ensure all 3 worker subnets for the worker nodes and 3 public subnets for the load balancers are created:

```
availability_domains = {        
    "bastion_ad1"     = "true"
    "bastion_ad2"     = "false"        
    "bastion_ad3"     = "false"        
    "lb_ad1"      = "true"        
    "lb_ad2"      = "true"        
    "lb_ad3"      = "false"        
    "workers_ad1" = "true"        
    "workers_ad2" = "true"        
    "workers_ad3" = "true"
}
```

In private mode, you also need to ensure that the NAT gateway is created and set a name for the gateway:

```
create_nat_gateway = "true"

nat_gateway_name = "okenat"
```

Refer to [nodepool topology][topology] to understand how this affects the number of worker subnets you need.

The bastion instances can be turned on and off as needed with no impact on OKE.

### OKE Network Policy

Network policy can be configured by using [calico][calico]. Calico installation is controlled by 2 parameters:

```
install_calico = "true"
calico_version = "3.3"
```

### OKE Node Pools and Nodes

OKE Parameters - see terraform.tfvars.example. Most of them are self-explanatory. The following are highlights:
   
   - Number of node pools are programmable. This is controlled by the node_pools variable.
   
   - Number of worker nodes per node pools are programmable. This is controlled by the node_pool_quantity_per_subnet variable.

   - Setting node_pools = "2" and node_pool_quantity_per_subnet = "2" and nodepool_topology = "2" will create a cluster of 8 worker nodes. Similarly, corresponding values of 3, 2, 2 will create a cluster of 12 worker nodes.
   
   - Review [Node pool topology][topology] to understand how these 3 parameters impact your deployment.

### Kubeconfig
kubeconfig is downloaded locally and stored in generated/kubeconfig. To interact with your cluster:

```
$ export KUBECONFIG=generated/kubeconfig
$ kubectl get nodes
```

### Addons
- [helm][helm] can also now be installed on the bastion instances by setting the install_helm=true in terraform.tfvars

## Accessing Dashboards

### Default Kubernetes Dashboard

1. Ensure you've enabled the Kubernetes Dashboard has been deployed by setting dashboard_enabled = 'true' in your terraform.tfvars file. See the [Terraform Configuration Parameters for OKE][terraform options].

2. Access the dashboard service:

    ```
    $ demo/dashboard.sh
    ```

3. Open the [Kubernetes Dashboard][kubernetes dashboard] in the browser and login with the kubeconfig file in the generated folder

### Service URLs to bookmark

| Service                   | URL                                                                                               |
| -----------------------   | -----------------------------------------------------------------------------------------------   |
| Default K8s Dashboard     | http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/   |

## Destroying the cluster

Run terraform destroy:

    ```
    $ terraform destroy
    ```

## Known Issues

- The subnet allocation algorithm must be tested more thoroughly for the 2-subnet node pool topology. At the moment, ensure all 3 worker subnets are enabled to avoid unknown problems.

- The imageocids for the bastion instances have been hardcoded to avoid an extra lookup. If you during a terraform run, the image cannot be found, check the available [image ocids][image ocids] and update the values accordingly in terraform.tfvars. Alternatively, you may supply your own image ocids. At the moment, all scripts are meant for Oracle Linux only, although they should work for CentOS too.

- You need to be part of Administrators' group in order to use instance_principals

- By default, the cluster is provisioned for 3-AD regions. For single AD regions, open the file modules/oke/cluster.tf and swap the service_lb_subnet_ids as follows:

    1. Uncomment line 12 by removing the # at the beginning of the line
    2. Comment line 15 by adding a # at the beginning of the line
    3. The code should look like this:

``` 
    # single ad regions
    service_lb_subnet_ids = ["${var.cluster_subnets["lb_ad1"]}"]

    # multi ad regions
    # service_lb_subnet_ids= ["${var.cluster_subnets["lb_ad1"]}", "${var.cluster_subnets["lb_ad2"]}"]

```
