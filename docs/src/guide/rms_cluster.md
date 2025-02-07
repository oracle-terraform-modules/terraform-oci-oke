[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/Q6OAh5KR9V1vjHZpj0o_ZjI0nzcpejV5xYG_qwrv1F5Vx8EH6JlXtjiqjj3Bilow/n/hpc_limited_availability/b/tfoke/o/oke-cluster-only.zip&zipUrlVariables={"cluster_name":"oke-cluster","create_vcn":false,"create_nsgs":false,"create_bastion":false,"worker_subnet_create":"Never","control_plane_subnet_create":"Never","operator_subnet_create":"Never","bastion_subnet_create":"Never","pod_subnet_create":"Never","int_lb_subnet_create":"Never","pub_lb_subnet_create":"Never"})

<p>
An OKE-managed Kubernetes cluster.
</p>

The following resources may be created depending on provided configuration:
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group>core_network_security_group</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group_security_rule>core_network_security_group_security_rule</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance>core_instance</a> (operator)
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster>containerengine_cluster</a>
