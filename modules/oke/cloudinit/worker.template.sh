#!/bin/bash

# DO NOT MODIFY
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh

## run oke provisioning script
bash -x /var/run/oke-init.sh

### adjust block volume size
/usr/libexec/oci-growfs -y

timedatectl set-timezone ${worker_timezone}

touch /var/log/oke.done