# Storage

## PVCs

## Local

## File Storage Service (FSS)

**NOTE:** Pending validation for 5.x, CSI

**Resources:**
* [oci_file_storage_export](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/file_storage_export)
* [oci_file_storage_export_set](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/file_storage_export_set)
* [oci_file_storage_file_system](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/file_storage_file_system)
* [oci_file_storage_mount_target](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/file_storage_mount_target)

The File Storage service instance will be created in a separate subnet with access configured using a network security group.

You can then review the following documentation for creating persistent volume claim and persistent volume using file storage

Refer to [Provisioning PVCs on the File Storage Service](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingpersistentvolumeclaim_Provisioning_PVCs_on_FSS.htm) for more information.

**CAUTION:** Running terraform destroy will remove the filesystem storage created using Terraform. Ensure you have taken the necessary backup if needed.
