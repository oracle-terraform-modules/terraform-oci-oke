# Extensions: Monitoring

****
**WARNING:** The following options are provided as a reference for evaluation only, and may install software to the cluster that is not supported by or sourced from Oracle. These features should be enabled with caution as their operation is not guaranteed!
****

## Metrics Server

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-metrics-server.auto.tfvars:4:}}
```

### References
* [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server)

****

## Prometheus

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-prometheus.auto.tfvars:4:}}
```

### References
* [prometheus.io](https://prometheus.io)
* [prometheus-community/kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

****

## DCGM Exporter

### Usage
```javascript
{{#include ../../../examples/extensions/vars-extensions-dcgm-exporter.auto.tfvars:4:}}
```

### References
* [NVIDIA/dcgm-exporter](https://github.com/NVIDIA/dcgm-exporter)

****
