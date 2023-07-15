[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.ap-osaka-1.oraclecloud.com/p/VYW4Rc8Q57asWu1DeqUrLkBZ7CMuNe6TsQdCfIsBUEMSLtH6a3zVD5zEwteRYlLW/n/hpc_limited_availability/b/tfoke/o/oke-network-only.zip)

<p>
Network resources configured for an OKE cluster.
</p>

The following resources may be created depending on provided configuration:
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn>core_vcn</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_nat_gateway>core_nat_gateway</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway>core_internet_gateway</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet>core_subnet</a>
* <a href=https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance>core_instance</a> (bastion)
