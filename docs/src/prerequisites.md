[uri-terraform-install]: https://developer.hashicorp.com/terraform/tutorials/oci-get-started/install-cli
# Prerequisites

This section will guide you through the prerequisites before you can use this project.

## Identity and Access Management Rights

The Terraform user must have the following permissions to:

* MANAGE dynamic groups (instance_principal and KMS integration)
* MANAGE cluster-family in compartment
* MANAGE virtual-network-family in compartment
* MANAGE instance-family in compartment

## Install Terraform
[Start by installing Terraform][uri-terraform-install] and configuring your path.

### Download Terraform
1. Open your browser and navigate to the [Terraform download page](https://www.terraform.io/downloads.html). You need version 1.0.0+.
1. Download the appropriate version for your operating system
1. Extract the the contents of compressed file and copy the terraform binary to a location that is in your path (see next section below)

### Configure path on Linux/macOS
Open a terminal and enter the following:
```bash, editable
# edit your desired path in-place:
sudo mv /path/to/terraform /usr/local/bin
```

### Configure path on Windows
Follow the steps below to configure your path on Windows:
1. Click on 'Start', type 'Control Panel' and open it
1. Select System > Advanced System Settings > Environment Variables
1. Select System variables > PATH and click 'Edit'
1. Click New and paste the location of the directory where you have extracted the terraform.exe
1. Close all open windows by clicking OK
1. Open a new terminal and verify terraform has been properly installed

### Testing Terraform installation
Open a terminal and test:
```bash
terraform -v
```

## Generate API keys
Follow the documentation for generating keys on [OCI Documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#two).

## Upload your API keys
Follow the documentation for uploading your keys on [OCI Documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#two).

Note the fingerprint.

## Create an OCI compartment
Follow the documentation for [creating a compartment](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingcompartments.htm#two).

## Obtain the necessary OCIDs
The following OCIDs are required:
* Compartment OCID
* Tenancy OCID
* User OCID

Follow the documentation for obtaining the tenancy and user ids on [OCI Documentation](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#five).

To obtain the compartment OCID:
1. Navigate to Identity > Compartments
2. Click on your Compartment
3. Locate OCID on the page and click on 'Copy'

If you wish to encrypt Kubernetes secrets with a key from [OCI KMS](https://docs.cloud.oracle.com/iaas/Content/KeyManagement/Tasks/managingkeys.htm), you also need to create [a vault](https://docs.cloud.oracle.com/iaas/Content/KeyManagement/Tasks/managingvaults.htm) and [a key](https://docs.cloud.oracle.com/iaas/Content/KeyManagement/Tasks/managingkeys.htm) and obtain the key id.

## Configure OCI Policy for OKE

Follow the documentation for [to create the necessary OKE policy](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengpolicyconfig.htm#PolicyPrerequisitesService).
