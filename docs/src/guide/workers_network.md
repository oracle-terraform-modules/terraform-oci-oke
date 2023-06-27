# Workers: Network

## Subnets
```javascript
{{#include ../../../examples/workers/vars-workers-network-subnets.auto.tfvars:4:}}
```

## Network Security Groups
```javascript
{{#include ../../../examples/workers/vars-workers-network-nsgs.auto.tfvars:4:}}
```

## Secondary VNICs
On pools with a self-managed `mode`:
```javascript
{{#include ../../../examples/workers/vars-workers-network-vnics.auto.tfvars:4:}}
```
