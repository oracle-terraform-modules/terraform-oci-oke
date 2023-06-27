  <tr>
    <td>
    <pre>mode = "instance-pool"</pre>
    A self-managed Compute Instance Pool for custom user-provisioned worker nodes.
    </td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group>identity_dynamic_group</a> (workers)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy>identity_policy</a> (JoinCluster)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration>core_instance_configuration</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_pool>core_instance_pool</a></li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Instance%20Pool","worker_pool_name":"oke-instance-pool"} target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>