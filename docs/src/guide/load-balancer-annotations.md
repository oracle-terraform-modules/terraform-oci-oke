# Load Balancer Annotations

This file defines a list of [Service][4] `type: LoadBalancer` annotations which are
supported by the `oci-cloud-controller-manager`.

All annotations are prefixed with `service.beta.kubernetes.io/` or `oci.oraclecloud.com/` or `oci-network-load-balancer.oraclecloud.com/` (for OCI Network Load Balancer specific annotations). For example:

```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx-service
  annotations:
    oci.oraclecloud.com/load-balancer-type: "lb"
    service.beta.kubernetes.io/oci-load-balancer-shape: "400Mbps"
    service.beta.kubernetes.io/oci-load-balancer-subnet1: "ocid..."
    service.beta.kubernetes.io/oci-load-balancer-subnet2: "ocid..."
    oci.oraclecloud.com/loadbalancer-policy: "IP_HASH"
    oci.oraclecloud.com/oci-network-security-groups: "ocid1..."
spec:
  ...
```

## Load balancer Type Annotation
- [Load Balancer][10] - used to load balance Layer 7 traffic
- [Network Load Balancer][9] - used to load balance Layer 4 traffic

| Name                                                                         | Description                                     | Default |
|------------------------------------------------------------------------------|-------------------------------------------------|---------|
| `oci.oraclecloud.com/load-balancer-type`                                     | Specifies the load balancer type ("lb", "nlb")  | `"lb" ` |

## Load balancer Specific Annotations

| Name                                                                         | Description                                                                                                                                                                                                                                                                      | Default                                          |                                         Example                                          |
|------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|:----------------------------------------------------------------------------------------:|
| `service.beta.kubernetes.io/oci-load-balancer-internal`                      | Create an [internal load balancer][1]. Cannot be modified after load balancer creation.                                                                                                                                                                                          | `false`                                          |                                         `false`                                          |
| `service.beta.kubernetes.io/oci-load-balancer-shape`                         | A template that determines the load balancer's total pre-provisioned capacity (bandwidth) for ingress plus egress traffic. Available shapes include `100Mbps`, `400Mbps`, `8000Mbps` and `flexible`. Use `oci lb shape list` to get the list of shapes supported on your account | `"100Mbps"`                                      |                                       `"100Mbps"`                                        |
| `service.beta.kubernetes.io/oci-load-balancer-shape-flex-min`                | A template that determines the load balancer's minimum pre-provisioned capacity (bandwidth) for ingress plus egress traffic. Only used when `oci-load-balancer-shape` is set to `flexible`.                                                                                      | `N/A`                                            |                                         `"100"`                                          |
| `service.beta.kubernetes.io/oci-load-balancer-shape-flex-max`                | A template that determines the load balancer's maximum pre-provisioned capacity (bandwidth) for ingress plus egress traffic. Only used when `oci-load-balancer-shape` is set to `flexible`.                                                                                      | `N/A`                                            |                                         `"100"`                                          |
| `service.beta.kubernetes.io/oci-load-balancer-subnet1`                       | The OCID of the one required regional subnet to attach the load balancer to OR The OCID of the first [subnet][2] of the two required Availability Domain specific subnets to attach the load balancer to. Must be in separate Availability Domains.                              | Value provided in config file                    |                                       `"ocid1..."`                                       |
| `service.beta.kubernetes.io/oci-load-balancer-subnet2`                       | The OCID of the second [subnet][2] of the two required subnets to attach the load balancer to. Must be in separate Availability Domains.                                                                                                                                         | Value provided in config file                    |                                       `"ocid1..."`                                       |
| `service.beta.kubernetes.io/oci-load-balancer-health-check-retries`          | The number of retries to attempt before a backend server is considered "unhealthy".                                                                                                                                                                                              | `3`                                              |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-health-check-timeout`          | The maximum time, in milliseconds, to wait for a reply to a [health check][6]. A [health check][6] is successful only if a reply returns within this timeout period.                                                                                                             | `3000`                                           |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-health-check-interval`         | The interval between [health checks][6] requests, in milliseconds.                                                                                                                                                                                                               | `10000`                                          |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-connection-idle-timeout`       | The maximum idle time, in seconds, allowed between two successive receive or two successive send operations between the client and backend servers.                                                                                                                              | `300` for TCP listeners, `60` for HTTP listeners |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-security-list-management-mode` | Specifies the [security list mode](##security-list-management-modes) (`"All"`, `"Frontend"`,`"None"`) to configure how security lists are managed by the CCM.                                                                                                                    | `"All"`                                          |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-backend-protocol`              | Specifies protocol on which the listener accepts connection requests. To get a list of valid protocols, use the [`ListProtocols`][5] operation.                                                                                                                                  | `"TCP"`                                          |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-ssl-ports`                     | The ports to enable SSL termination on the corresponding load balancer listener                                                                                                                                                                                                  | `443`                                            |                                                                                          |
| `service.beta.kubernetes.io/oci-load-balancer-tls-secret`                    | The TLS secret to install on the load balancer listeners which have SSL enabled.                                                                                                                                                                                                 | `N/A`                                            |                                                                                          |
| `oci.oraclecloud.com/oci-network-security-groups`                            | Specifies Network Security Groups' OCIDs to be associated with the loadbalancer. Please refer [here][8] for NSG details. Example NSG OCID: `ocid1.networksecuritygroup.oc1.iad.aaa`                                                                                              | `N/A`                                            |                               `"ocid1...aaa, ocid1...bbb"`                               |
| `oci.oraclecloud.com/loadbalancer-policy`                                    | Specifies loadbalancer traffic policy for the loadbalancer. To get a list of valid policies, use the [`ListPolicies`][7] operation.                                                                                                                                              | `"ROUND_ROBIN"`                                  |                                                                                          |
| `oci.oraclecloud.com/initial-defined-tags-override`                          | Specifies one or more Defined tags to apply to the OCI Load Balancer.                                                                                                                                                                                                            | `N/A`                                            |                 `'{"namespace1": {"tag1": "value1", "tag2": "value2"}}'`                 |
| `oci.oraclecloud.com/initial-freeform-tags-override`                         | Specifies one or more Freeform tags to apply to the OCI Load Balancer.                                                                                                                                                                                                           | `N/A`                                            |                         `'{"tag1": "value1", "tag2": "value2"}'`                         |
| `oci.oraclecloud.com/node-label-selector`                                    | Specifies which nodes to add as a backend to the OCI Load Balancer.                                                                                                                                                                                                              | `N/A`                                            |                                                                                          |
| `oci.oraclecloud.com/security-rule-management-mode`                          | Specifies the security rule management mode ("SL-All", "SL-Frontend", "NSG", "None") that configures how security lists are managed by the CCM                                                                                                                                   | `N/A`                                            |                                         `"NSG"`                                          |
| `oci.oraclecloud.com/oci-backend-network-security-group`                     | Specifies backend Network Security Group(s)' OCID(s) for management of ingress / egress security rules for the LB/NLB by the CCM. Example NSG OCID: `ocid1.networksecuritygroup.oc1.iad.aaa`                                                                                     | `N/A`                                            |                               `"ocid1...aaa, ocid1...bbb"`                               |
| `oci.oraclecloud.com/oci-load-balancer-listener-ssl-config`                  | Specifies the cipher suite on the listener of the LB managed by CCM.                                                                                                                                                                                                             | `N/A`                                            | `'{"CipherSuiteName":"oci-default-http2-ssl-cipher-suite-v1", "Protocols":["TLSv1.2"]}'` |
| `oci.oraclecloud.com/oci-load-balancer-backendset-ssl-config"`               | Specifies the cipher suite on the backendsets of the LB managed by CCM.                                                                                                                                                                                                          | `N/A`                                            | `'{"CipherSuiteName":"oci-default-http2-ssl-cipher-suite-v1", "Protocols":["TLSv1.2"]}'` |
| `oci.oraclecloud.com/ingress-ip-mode`                                        | Specifies ".status.loadBalancer.ingress.ipMode" for a Service with type set to LoadBalancer. Refer: [Specifying IPMode to adjust traffic routing][11]                                                                                                                            | `VIP`                                            |                                        `"proxy"`                                         |


Note:
- Only one annotation `oci-load-balancer-subnet1` should be passed if it is a regional subnet.
- `oci-network-security-groups` uses `oci.oraclecloud.com/` as prefix.
- `loadbalancer-policy` and `oci-network-security-groups` use `oci.oraclecloud.com/` as prefix.
## TLS-related

| Name                           | Description                                                                         | Default |
|--------------------------------|-------------------------------------------------------------------------------------|---------|
| `oci-load-balancer-tls-secret` | A reference in the form `<namespace>/<secretName>` to a Kubernetes [TLS secret][3]. | `""`    |
| `oci-load-balancer-ssl-ports`  | A `,` separated list of port number(s) for which to enable SSL termination.         | `""`    |

## Security List Management Modes
| Mode         | Description                                                                                                                                                                                                                                                                                                     |
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `"All"`      | CCM will manage all required security list rules for load balancer services                                                                                                                                                                                                                                     |
| `"Frontend"` | CCM will manage  only security list rules for ingress to the load balancer. Requires that the user has setup a rule that allows inbound traffic to the appropriate ports for kube proxy health port, node port ranges, and health check port ranges.                                                            |
| `"None`"     | Disables all security list management. Requires that the user has setup a rule that allows inbound traffic to the appropriate ports for kube proxy health port, node port ranges, and health check port ranges. *Additionally, requires the user to mange rules to allow inbound traffic to load balancers.*    |

Note:
- If an invalid mode is passed in the annotation, then the default (`"All"`) mode is configured.
- If an annotation is not specified, the mode specified in the cloud provider config file is configured.

## Network Load Balancer Specific Annotations

| Name                                                                       | Description                                                                                                                                                                                  | Default                                   |
|----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `oci-network-load-balancer.oraclecloud.com/internal`                       | Create an [internal network load balancer][1]. Cannot be modified after load balancer creation.                                                                                              | `false`                                   |
| `oci-network-load-balancer.oraclecloud.com/subnet`                         | The OCID of the required regional or AD specific subnet to attach the network load balancer.	                                                                                                | Value set for the cluster                 |
| `oci-network-load-balancer.oraclecloud.com/oci-network-security-groups`    | Specifies Network Security Groups' OCIDs to be associated with the network load balancer.	                                                                                                   | `""`                                      |
| `oci-network-load-balancer.oraclecloud.com/initial-freeform-tags-override` | Specifies one or multiple Freeform tags to apply to the OCI Network Load Balancer. Valid values: `'{"tag1": "value1", "tag2": "value2"}'`                                                    | `""`                                      |
| `oci-network-load-balancer.oraclecloud.com/initial-defined-tags-override`  | Specifies one or multiple Defined tags to apply to the OCI Network Load Balancer.  Valid values: `'{"namespace1": {"tag1": "value1", "tag2": "value2"}}'`                                    | `""`                                      |
| `oci-network-load-balancer.oraclecloud.com/health-check-retries`           | The number of retries to attempt before a backend server is considered "unhealthy".	                                                                                                         | `3`                                       |
| `oci-network-load-balancer.oraclecloud.com/health-check-timeout`           | The maximum time, in milliseconds, to wait for a reply to a health check. A health check is successful only if a reply returns within this timeout period.                                   | `3000`                                    |
| `oci-network-load-balancer.oraclecloud.com/health-check-interval`          | The interval between health checks requests, in milliseconds.                                                                                                                                | `3000`                                    |
| `oci-network-load-balancer.oraclecloud.com/backend-policy`                 | The network load balancer policy for the backend set. Valid values: "TWO_TUPLE", "THREE_TUPLE", or "FIVE_TUPLE"		                                                                            | `"FIVE_TUPLE"`                            |
| `oci-network-load-balancer.oraclecloud.com/security-list-management-mode`  | Specifies the security list mode ("All", "Frontend","None") to configure how security lists are managed.		                                                                                   | `"None"`                                  |
| `oci-network-load-balancer.oraclecloud.com/node-label-selector`            | Specifies which nodes to add as a backend to the OCI Network Load Balancer.		                                                                                                                | `"None"`                                  |
| `oci-network-load-balancer.oraclecloud.com/is-preserve-source`             | Enable or disable the network load balancer to preserve source address of incoming traffic. Can be set only when externalTrafficPolicy is set to Local.	                                     | `"true" (if externalTrafficPolicy=Local)` |
| `oci.oraclecloud.com/security-rule-management-mode`                        | Specifies the security rule management mode ("SL-All", "SL-Frontend", "NSG", "None") that configures how security lists are managed by the CCM                                               | `N/A`                                     |
| `oci.oraclecloud.com/oci-backend-network-security-group`                   | Specifies backend Network Security Group(s)' OCID(s) for management of ingress / egress security rules for the LB/NLB by the CCM. Example NSG OCID: `ocid1.networksecuritygroup.oc1.iad.aaa` | `N/A`                                     |
| `oci.oraclecloud.com/ingress-ip-mode`                                      | Specifies ".status.loadBalancer.ingress.ipMode" for a Service with type set to LoadBalancer. Refer: [Specifying IPMode to adjust traffic routing][11]                                        | `VIP`                                     |
| `oci-network-load-balancer.oraclecloud.com/is-ppv2-enabled`                | To enable/disable PPv2 feature for the listeners of your NLB managed by the CCM.                                                                                                             | `false`                                   |

Note:
- The only security list management mode allowed when backend protocol is UDP is "None"

## Network Load Balancer

For example:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: example-nlb
  annotations:
    oci-network-load-balancer.oraclecloud.com/security-list-management-mode: "All"
    oci.oraclecloud.com/load-balancer-type: nlb
spec:
  selector:
    app: example-nlb
  ports:
    - port: 8088
      targetPort: 80
  type: LoadBalancer
  externalTrafficPolicy: Local
```

Note:
- The only security list management mode allowed when backend protocol is UDP is "None"
- `externalTrafficPolicy` should be "Local" for preserving source IP
- We recommend to set the `security-list-management-mode` as "None" and configure NSG / Security rules on your own.
- The new `security-rule-management-mode`: `"NSG"` provides a better way to manage your Load Balancer/NLB Security Rules via CCM.


[1]: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
[2]: https://docs.us-phoenix-1.oraclecloud.com/Content/Network/Tasks/managingVCNs.htm
[3]: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
[4]: https://kubernetes.io/docs/concepts/services-networking/service/
[5]: https://docs.cloud.oracle.com/iaas/api/#/en/loadbalancer/20170115/LoadBalancerProtocol/ListProtocols
[6]: https://docs.cloud.oracle.com/en-us/iaas/api/#/en/loadbalancer/20170115/HealthChecker/
[7]: https://docs.oracle.com/en-us/iaas/api/#/en/loadbalancer/20170115/LoadBalancerPolicy/ListPolicies
[8]: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm
[9]: https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/introducton.htm#Overview
[10]: https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm
[11]: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringloadbalancersnetworkloadbalancers-subtopic.htm#contengcreatingloadbalancer_topic_Specifying_IPMode
