# Load Balancers

## Using Dynamic and Flexible Load Balancers

When you create a service of type LoadBalancer, by default, an OCI Load Balancer with dynamic shape 100Mbps will be created.

.You can override this shape by using the {uri-oci-loadbalancer-annotations}[OCI Load Balancer Annotations]. In order to keep using the dynamic shape but change the available total bandwidth to 400Mbps, use the following annotation on your LoadBalancer service:
```json
service.beta.kubernetes.io/oci-load-balancer-shape: "400Mbps"
```

Configure `flexible` shape with bandwidth:
```json
service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: 50
service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: 200
```

## References

* [Load Balancer Annotations](https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/load-balancer-annotations.md)
* [Specifying Alternative Load Balancer Shapes](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm#Specifyi)
* [Flexible Load Balancers](https://medium.com/@lmukadam/creating-flexible-oci-load-balancers-with-oke-bd98e0318976)
