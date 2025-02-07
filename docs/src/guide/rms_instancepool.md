[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/Q6OAh5KR9V1vjHZpj0o_ZjI0nzcpejV5xYG_qwrv1F5Vx8EH6JlXtjiqjj3Bilow/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Instance%20Pool","worker_pool_name":"oke-instance-pool"})

<p>
A self-managed Compute Instance Pool for custom user-provisioned worker nodes.

Configured with `mode = "instance-pool"` on a `worker_pools` entry, or with `worker_pool_mode = "instance-pool"` to use as the default for all pools unless otherwise specified.
</p>

The following resources may be created depending on provided configuration:
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group>identity_dynamic_group</a> (workers)
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy>identity_policy</a> (JoinCluster)
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration>core_instance_configuration</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_pool>core_instance_pool</a>
