# Deploy the OKE Terraform Module

## Prerequisites
* [Required Keys and OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)
* [Required IAM policies](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengpolicyconfig.htm#PolicyPrerequisitesService)
* `git`, `ssh` client to run locally
* Terraform `>= 1.2.0` to run locally

## Provisioning from an OCI Resource Manager Stack
<table>
  <tr>
    <th>Name</th>
    <th>Resources</th>
    <th>Deploy</th>
  </tr>
  <tr>
    <td>Network</td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn>core_vcn</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_nat_gateway>core_nat_gateway</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway>core_internet_gateway</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet>core_subnet</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance>core_instance</a> (bastion)</li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-network-only.zip target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>
  <tr>
    <td>Cluster</td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group>core_network_security_group</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group_security_rule>core_network_security_group_security_rule</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance>core_instance</a> (operator)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster>containerengine_cluster</a></li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-cluster-only.zip&zipUrlVariables={"cluster_name":"oke-cluster-existing-network","create_vcn":false,"create_nsgs":false,"create_bastion":false,"worker_subnet_create":"Never","control_plane_subnet_create":"Never","operator_subnet_create":"Never","bastion_subnet_create":"Never","pod_subnet_create":"Never","int_lb_subnet_create":"Never","pub_lb_subnet_create":"Never"} target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>
  <tr>
    <td>OKE-Managed Node Pool</td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool>containerengine_node_pool</a></li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Node%20Pool","worker_pool_name":"oke-node-pool"} target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>
  <tr>
    <td>Self-Managed Instances</td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group>identity_dynamic_group</a> (workers)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy>identity_policy</a> (JoinCluster)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance>core_instance</a></li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Instances","worker_pool_name":"oke-instances"} target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>
  <tr>
    <td>Self-Managed Instance Pool</td>
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
  <tr>
    <td>Self-Managed Cluster Network</td>
    <td>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group>identity_dynamic_group</a> (workers)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy>identity_policy</a> (JoinCluster)</li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration>core_instance_configuration</a></li>
      <li><a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cluster_network>core_cluster_network</a></li>
    </td>
    <td><a href=https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-workers-only.zip&zipUrlVariables={"worker_pool_mode":"Cluster%20Network","worker_pool_name":"oke-cluster-network","worker_shape":"BM.GPU.B4.8","worker_boot_volume_size":"200"} target="_blank">
        <img src="https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg" alt="Deploy to Oracle Cloud"/></a>
    </td>
  </tr>
</table>
