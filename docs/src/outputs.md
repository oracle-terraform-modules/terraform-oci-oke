# Outputs

## Identity Access Management (IAM)
<!-- BEGIN_TF_IAM -->

* **`dynamic_group_ids`**&nbsp;&nbsp; Cluster IAM dynamic group IDs
* **`policy_statements`**&nbsp;&nbsp; Cluster IAM policy statements

<!-- END_TF_IAM -->

## Network
<!-- BEGIN_TF_NETWORK -->

* **`bastion_nsg_id`**&nbsp;&nbsp; 
* **`bastion_subnet_cidr`**&nbsp;&nbsp; 
* **`bastion_subnet_id`**&nbsp;&nbsp; Return configured/created subnet IDs and CIDRs when applicable
* **`control_plane_nsg_id`**&nbsp;&nbsp; 
* **`control_plane_subnet_cidr`**&nbsp;&nbsp; 
* **`control_plane_subnet_id`**&nbsp;&nbsp; 
* **`fss_nsg_id`**&nbsp;&nbsp; 
* **`fss_subnet_cidr`**&nbsp;&nbsp; 
* **`fss_subnet_id`**&nbsp;&nbsp; 
* **`int_lb_nsg_id`**&nbsp;&nbsp; 
* **`int_lb_subnet_cidr`**&nbsp;&nbsp; 
* **`int_lb_subnet_id`**&nbsp;&nbsp; 
* **`network_security_rules`**&nbsp;&nbsp; 
* **`nsg_ids`**&nbsp;&nbsp; 
* **`operator_nsg_id`**&nbsp;&nbsp; 
* **`operator_subnet_cidr`**&nbsp;&nbsp; 
* **`operator_subnet_id`**&nbsp;&nbsp; 
* **`pod_nsg_id`**&nbsp;&nbsp; 
* **`pod_subnet_cidr`**&nbsp;&nbsp; 
* **`pod_subnet_id`**&nbsp;&nbsp; 
* **`pub_lb_nsg_id`**&nbsp;&nbsp; 
* **`pub_lb_subnet_cidr`**&nbsp;&nbsp; 
* **`pub_lb_subnet_id`**&nbsp;&nbsp; 
* **`worker_nsg_id`**&nbsp;&nbsp; 
* **`worker_subnet_cidr`**&nbsp;&nbsp; 
* **`worker_subnet_id`**&nbsp;&nbsp; 

<!-- END_TF_NETWORK -->

## Bastion
<!-- BEGIN_TF_BASTION -->

* **`id`**&nbsp;&nbsp; 
* **`public_ip`**&nbsp;&nbsp; 

<!-- END_TF_BASTION -->

## Cluster
<!-- BEGIN_TF_CLUSTER -->

* **`cluster_id`**&nbsp;&nbsp; 
* **`cluster_endpoints`**&nbsp;&nbsp; 
* **`cluster_oidc_discovery_endpoint`**&nbsp;&nbsp; 
* **`cluster_kubeconfig`**&nbsp;&nbsp; 
* **`cluster_ca_cert`**&nbsp;&nbsp; 

<!-- END_TF_CLUSTER -->

## Workers
<!-- BEGIN_TF_WORKERS -->

* **`worker_count_expected`**&nbsp;&nbsp; # of nodes expected from created worker pools
* **`worker_drain_expected`**&nbsp;&nbsp; # of nodes expected to be draining in worker pools
* **`worker_instances`**&nbsp;&nbsp; Created worker pools (mode == 'instance')
* **`worker_pool_autoscale_expected`**&nbsp;&nbsp; # of worker pools expected with autoscale enabled from created worker pools
* **`worker_pool_ids`**&nbsp;&nbsp; Created worker pool IDs
* **`worker_pool_ips`**&nbsp;&nbsp; Created worker instance private IPs by pool for available modes ('node-pool', 'instance').
* **`worker_pools`**&nbsp;&nbsp; Created worker pools (mode != 'instance')

<!-- END_TF_WORKERS -->

## Operator
<!-- BEGIN_TF_OPERATOR -->

* **`id`**&nbsp;&nbsp; 
* **`private_ip`**&nbsp;&nbsp; 

<!-- END_TF_OPERATOR -->
