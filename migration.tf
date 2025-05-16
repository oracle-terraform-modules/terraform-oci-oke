# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Subnets

moved {
  from = module.network.oci_core_subnet.cp
  to   = module.network.oci_core_subnet.oke["cp"]
}
moved {
  from = module.bastion[0].oci_core_subnet.bastion
  to   = module.network.oci_core_subnet.oke["bastion"]
}
moved {
  from = module.operator[0].oci_core_subnet.operator
  to   = module.network.oci_core_subnet.oke["operator"]
}
moved {
  from = module.network.oci_core_subnet.int_lb[0]
  to   = module.network.oci_core_subnet.oke["int_lb"]
}
moved {
  from = module.network.oci_core_subnet.pub_lb[0]
  to   = module.network.oci_core_subnet.oke["pub_lb"]
}
moved {
  from = module.network.oci_core_subnet.workers
  to   = module.network.oci_core_subnet.oke["workers"]
}
moved {
  from = module.network.oci_core_subnet.pods
  to   = module.network.oci_core_subnet.oke["pods"]
}
moved {
  from = module.network.oci_core_subnet.fss
  to   = module.network.oci_core_subnet.oke["fss"]
}

# Cluster

moved {
  from = module.oke.oci_containerengine_cluster.k8s_cluster
  to   = module.cluster[0].oci_containerengine_cluster.k8s_cluster
}

# Workers

moved {
  from = module.oke.oci_containerengine_node_pool.nodepools
  to   = module.workers[0].oci_containerengine_node_pool.workers
}

moved {
  from = module.workers[0].oci_containerengine_node_pool.workers
  to   = module.workers[0].oci_containerengine_node_pool.tfscaled_workers
}

moved {
  from = module.workers[0].oci_core_instance_pool.workers
  to   = module.workers[0].oci_core_instance_pool.tfscaled_workers
}