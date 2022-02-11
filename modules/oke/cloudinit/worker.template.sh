Content-Type: multipart/mixed; boundary=MIMEBOUNDARY
MIME-Version: 1.0

--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: text/cloud-config
Mime-Version: 1.0

#cloud-config
timezone: ${worker_timezone}

#!/bin/bash

### install oci util
yum install -y python36-oci-sdk

### adjust block volume size
until oci-growfs -y
do
    echo "Failed to increase block volume size. Sleeping for 30s"
    sleep 30
done
echo "Block volume size adjusted"

## get default OKE provisioning script
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh

## run oke provisioning script
until bash -x /var/run/oke-init.sh
do
    echo "Failed to run OKE init successfully. Sleeping for 30s"
    sleep 30
done
echo "OKE Provisioning completed"