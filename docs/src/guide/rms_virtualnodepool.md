[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/Q6OAh5KR9V1vjHZpj0o_ZjI0nzcpejV5xYG_qwrv1F5Vx8EH6JlXtjiqjj3Bilow/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Virtual%20Node%20Pool","worker_pool_name":"oke-virtual-node-pool"})

<p>
An OKE-managed Virtual Node Pool.

Configured with `mode = "virtual-node-pool"` on a `worker_pools` entry, or with `worker_pool_mode = "virtual-node-pool"` to use as the default for all pools unless otherwise specified.
</p>

The following resources may be created depending on provided configuration:
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_virtual_node_pool>containerengine_virtual_node_pool</a>
