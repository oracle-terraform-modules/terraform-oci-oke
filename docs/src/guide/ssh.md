# SSH

See also:
* [Connecting to Your Linux Instance Using SSH](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/testingconnection.htm#connecting)
* [Log In to a VM Using SSH](https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/log-vm-using-ssh.html)

## Configure SSH

SSH keys must be configured for access to instances through the bastion host:
```properties
ssh_private_key_path = "~/.ssh/id_rsa"
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
```

Private keys may also be managed by the SSH agent:
```shell
ssh-add -L                     # show current keys
chmod 600 <private key>        # ensure correct permissions on key
ssh-add <private key>          # add private key
ssh -J opc@bastion opc@target  # `-i <private key>` not needed
```

**TODO:** Add content
