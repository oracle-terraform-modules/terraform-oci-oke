# Operator: SSH

Command usage for `ssh` through the created bastion to the operator host is included in the module's output:
```shell
$ terraform output
cluster = {
  "bastion_public_ip" = "138.0.0.1"
  "ssh_to_operator" = "ssh -J opc@138.0.0.1 opc@10.0.0.16"
  ...
}

$ ssh -J opc@138.0.0.1 opc@10.0.0.16 kubectl get nodes
NAME          STATUS   ROLES    AGE     VERSION
10.1.48.175   Ready    node     7d10h   v1.25.6
10.1.50.102   Ready    node     3h12m   v1.25.6
10.1.52.76    Ready    node     7d10h   v1.25.6
10.1.54.237   Ready    node     5h41m   v1.25.6
10.1.58.74    Ready    node     5h22m   v1.25.4
10.1.62.90    Ready    node     3h12m   v1.25.6
```
