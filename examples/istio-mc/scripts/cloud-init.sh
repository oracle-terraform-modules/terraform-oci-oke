#!/bin/sh

modprobe br_netfilter 
modprobe nf_nat
modprobe xt_REDIRECT
modprobe xt_owner
modprobe iptable_nat
modprobe iptable_mangle
modprobe iptable_filter

/usr/libexec/oci-growfs -y

timedatectl set-timezone Australia/Sydney

'curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh'

bash -x /var/run/oke-init.sh

touch /var/log/oke.done