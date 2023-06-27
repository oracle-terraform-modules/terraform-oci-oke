# Configuration

This section assumes you have completed all the {uri-prereqs}[Prerequisites].

## Identity

Enter the values for the following parameters in the terraform.tfvars file:

* api_fingerprint
* api_private_key_path
* compartment_id
* tenancy_id
* user_id

For example:

```properties
api_fingerprint = "1a:bc:23:45:6d:78:e9:f0:gh:ij:kl:m1:23:no:4p:5q"
```

Alternatively, you can also specify these using Terraform environment variables by prepending TF_variable_name e.g.

```properties
export TF_api_fingerprint = "1a:bc:23:45:6d:78:e9:f0:gh:ij:kl:m1:23:no:4p:5q"
```

## OCI parameters

The 3 OCI parameters here mainly concern:

* `compartment_id`: is the compartment where all the resources will be created in
* `region`: this allows you to select the region where you want the OKE cluster deployed

For example:

```properties
compartment_id = "ocid1.compartment...."
home_region = "us-phoenix-1"
region = "ap-sydney-1"
```

Regions must have exactly 2 entries as above:

* home_region: is the tenancy's home region. This may be different from the region where you want to create OKE.
* region: is the actual region where you want to create the OKE cluster.

The list of regions can be found [here](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm).
