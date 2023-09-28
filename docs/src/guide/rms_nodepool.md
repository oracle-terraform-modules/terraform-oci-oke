[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Node%20Pool","worker_pool_name":"oke-node-pool"})

<p>
A standard OKE-managed pool of worker nodes with enhanced feature support.

Configured with `mode = "node-pool"` on a `worker_pools` entry, or with `worker_pool_mode = "node-pool"` to use as the default for all pools unless otherwise specified.
</p>

You can set the `image_type` attribute to one of the following values: 
  - `oke` (default)
  - `platform`
  - `custom`.

When the `image_type` is equal to `oke` or `platform` there is a high risk for the node-pool image to be updated on subsequent `terraform apply` executions because the module is using a [datasource](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/containerengine_node_pool_option) to fetch the latest images available.

To avoid this situation, you can set the `image_type` to `custom` and the `image_id` to the OCID of the image you want to use for the node-pool. 

The following resources may be created depending on provided configuration:
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool>containerengine_node_pool</a>
