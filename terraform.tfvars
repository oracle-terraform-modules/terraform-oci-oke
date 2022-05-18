# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl


api_fingerprint = "4d:10:ea:4f:0b:c6:ac:8a:c0:cb:76:50:1d:63:8e:12"
api_private_key_path = "oci_api_key.pem"
home_region = "eu-frankfurt-1"
region = "eu-frankfurt-1"
tenancy_id = "ocid1.tenancy.oc1..aaaaaaaagozl47dkv6gpbkffed5imrm3f6rjiwamxhz5ns7m2wqwfoplhhzq"
user_id = "ocid1.user.oc1..aaaaaaaawqmr6lc2jj3s6gv2kjxebmr6vndbz3ykfp653cq2zkz3zocfdeoq"


# general oci parameters
compartment_id = "ocid1.compartment.oc1..aaaaaaaamluifb5mxw2tiexvy5m4dga2phffeshb2efk7w7xbf5mnqplsceq"
label_prefix   = "dev"

# ssh keys
#ssh_private_key      = ""
ssh_private_key    = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAwREUzKQXovrykjUnLKeV7SEd7UoG58522qsYjZSfdabTjm9E
BYoWe807HBSMwLju6wj+joVg8pxASsow1PdoiZmWwMfTsMB+4CqhMXkXZxoKN7VA
Nw3vXukIw+cInutGkxjfDT+ZjR83ZS3IqcaRbxILlzTr14vR7O7Xb5biQ3cLGZnn
Do4RCyK1EZlfpwLztdTl32NDlUaZFZJurhn3gYx7sl/73llopCkSd+JpDHKr0OQo
WDoYWZF8Z/wn2wKnRkHqGFnmP7xfjqzLL/fqCTF2XmIE4hQfntF4HcS13sGVhZqW
EYXmXCJvvUpisCbEiIJQzcmkrcLSfcZjhL/HnQIDAQABAoIBAQCEQc5MzdA/XseT
LwRSC8+h7QDST9bhL0euTmz4eCqwbwMX3NLtNIZoctQeTVmKoGVS7wtq2KXsLOvC
EDZZfc7IDEYAdCNpPsTrjWh1Oq20fFsphGmkDVDAZMUTZo46R5RGKlCKg9oNmafa
EP4Yh6WTP/per+sr8mVxeMBueh8v9Qi+8ua+JEWMq2P+waDn/q8rPMU9vR4WAWC9
1pWynsstkDSmq+d0sFtuK4JdcP2u+6IWFaAEcBmwglv+jLyIFYjZAB6ev5x2DuUI
LSui7UOHQHmu/0+wHrTywGaE8bxMRfx7xT8m0GC6Ckit3rKIMEOLvWx7t3flhzeg
hKtaKOxBAoGBAOr4oIggG4atk1tQwsAXU4iTjMjCK+VnY65x7mGxjUQsb4FBK8Qq
rISS0RQSIGlBviH7pjXni4K9tRmFHeAInrsD6H7JUko44gqoBkRClwPnbyX/4I/J
jacbeA+ks0Jh22AQNIWX0c721HqdvlqmTC7ZN1tSUiPZgg3squP6jThRAoGBANJY
Y9mC4ZNLofKGjvLZg4zyyGM2yGpkhDdJcRB5n9r3ZTw6p1O5icyFN+YT8kdpWZCx
v1ofb7p4VIo/vFofBwXr9J4yIqjUgB3hTm9XqYrUwyWWrwluIsGPr9LD+22I5SHr
JoliZrt6y8iiQw7hu//pL/alDZ2emD6LQVmgfdONAoGAE9sCpb4g1VahlxvR+S1/
b5EYWnaeAvqjn8Ac5sB8MYCXw5JgQmlgvqsxY8LMXlih2nlLaE6yqU+imA95oM7Z
qu//m4cjnwYDg+cC8I23+Sp7Z/ihX0Um5TIbCSdfxoJCaXG1Hnzfy99rwRjHVx2q
XmMYnGzuZ/0fUlHndvBbMqECgYEAiQ04eceSTJOyAEB2MXtSAGtL74EJUnENyKwc
dBya8GPTXUvmLGIui8idJFcIvEjDJ8j4obLr7HZstutSQPIIdG5KIy0Nci2LEGz1
2wwmFqQMRpiIkb9l+/IwIEa7sqHIkbISmN85ipw23RIEWVTxVovMSYs/dNyZ296G
BOzSLx0CgYBhMyubDYSacTRKi/6QVnYLGRrby7i+Nif+JnOjlRiBACNXwo4JaboM
eAdRwQwZIAI37EICitOQP0V7LpRuzTBCUVfA8UwG/Q0gqEEjks9/dayRPqBYwlpZ
Ogr9IXr6NarPA4ZD6MbQ31SHOfWeKOhvgQgJm5jbaMsqC3Vj/8eT/w==
-----END RSA PRIVATE KEY-----
EOT
#ssh_private_key_path = "~/.ssh/id_rsa"
ssh_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBERTMpBei+vKSNScsp5XtIR3tSgbnznbaqxiNlJ91ptOOb0QFihZ7zTscFIzAuO7rCP6OhWDynEBKyjDU92iJmZbAx9OwwH7gKqExeRdnGgo3tUA3De9e6QjD5wie60aTGN8NP5mNHzdlLcipxpFvEguXNOvXi9Hs7tdvluJDdwsZmecOjhELIrURmV+nAvO11OXfY0OVRpkVkm6uGfeBjHuyX/veWWikKRJ34mkMcqvQ5ChYOhhZkXxn/CfbAqdGQeoYWeY/vF+OrMsv9+oJMXZeYgTiFB+e0XgdxLXewZWFmpYRheZcIm+9SmKwJsSIglDNyaStwtJ9xmOEv8ed"
# ssh_public_key_path  = "none"
#ssh_public_key_path = "~/.ssh/id_rsa.pub"

# networking
create_drg                   = false
drg_display_name             = "drg"

internet_gateway_route_rules = []

local_peering_gateways = {}

lockdown_default_seclist = true

nat_gateway_route_rules = []

nat_gateway_public_ip_id = "none"

subnets = {
  bastion  = { netnum = 0, newbits = 13 }
  operator = { netnum = 1, newbits = 13 }
  cp       = { netnum = 2, newbits = 13 }
  int_lb   = { netnum = 16, newbits = 11 }
  pub_lb   = { netnum = 17, newbits = 11 }
  workers  = { netnum = 1, newbits = 2 }
}

vcn_cidrs     = ["10.0.0.0/16"]
vcn_dns_label = "oke"
vcn_name      = "vcnoke"

# bastion host
create_bastion_host = false
bastion_access      = ["anywhere"]
bastion_image_id    = "Autonomous"
bastion_os_version  = "7.9"
bastion_shape = {
  shape            = "VM.Standard.E4.Flex",
  ocpus            = 1,
  memory           = 4,
  boot_volume_size = 50
}
bastion_state    = "RUNNING"
bastion_timezone = "Europe/Amsterdam"
bastion_type     = "public"
upgrade_bastion  = false

## bastion notification
enable_bastion_notification   = false
bastion_notification_endpoint = ""
bastion_notification_protocol = "EMAIL"
bastion_notification_topic    = "bastion_server_notification"

# bastion service
create_bastion_service        = false
bastion_service_access        = ["0.0.0.0/0"]
bastion_service_name          = "bastion"
bastion_service_target_subnet = "operator"

# operator host
create_operator                    = true
operator_image_id                  = "Oracle"
enable_operator_instance_principal = true
operator_nsg_ids                   = []
operator_os_version                = "8"
operator_shape = {
  shape            = "VM.Standard.E4.Flex",
  ocpus            = 1,
  memory           = 4,
  boot_volume_size = 50
}
operator_state    = "RUNNING"
operator_timezone = "Europe/Amsterdam"
upgrade_operator  = false

## operator notification
enable_operator_notification   = false
operator_notification_endpoint = ""
operator_notification_protocol = "EMAIL"
operator_notification_topic    = ""

# availability_domains
availability_domains = {
  bastion  = 1,
  operator = 1
}

# oke cluster options
admission_controller_options = {
  PodSecurityPolicy = false
}
allow_node_port_access       = false
allow_worker_internet_access = true
allow_worker_ssh_access      = false
cluster_name                 = "oke"
control_plane_type         = "private"
control_plane_allowed_cidrs  = ["0.0.0.0/0"]
control_plane_nsgs           = []
dashboard_enabled            = true
kubernetes_version           = "v1.21.5"
pods_cidr                    = "10.244.0.0/16"
services_cidr                = "10.96.0.0/16"

## oke cluster kms integration
use_encryption = false
kms_key_id     = ""

## oke cluster container image policy and keys
use_signed_images = false
image_signing_keys = []

# node pools
check_node_active = "all"
node_pools = {
  np1 = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 1, boot_volume_size = 150, label = { app = "frontend", pool = "np1" } }
  np2 = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 1, boot_volume_size = 150, label = { app = "frontend", pool = "np2" } }
  # np3 = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 1, boot_volume_size = 150, label = { app = "frontend", pool = "np1" } }
  # np4 = { shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 16, node_pool_size = 1, boot_volume_size = 150, label = { app = "frontend", pool = "np1" } }
  # np2 = {shape="VM.Standard.E4.Flex",ocpus=4,memory=16,node_pool_size=1,boot_volume_size=150, label={app="backend",pool="np2"}}
  # np3 = {shape="VM.Standard.A1.Flex",ocpus=8,memory=16,node_pool_size=1,boot_volume_size=150, label={pool="np3"}}
  # np4 = {shape="BM.Standard2.52",node_pool_size=1,boot_volume_size=150}
  # np5 = {shape="VM.Optimized3.Flex",node_pool_size=6}
  # np5 = {shape="BM.Standard.A1.160",node_pool_size=6}
  # np6 = {shape="VM.Standard.E2.2", node_pool_size=5}
  # np7 = {shape="BM.DenseIO2.52", node_pool_size=5}
  # np8 = {shape="BM.GPU3.8", node_pool_size=1}
  # np9 = {shape="BM.GPU4.8", node_pool_size=5}
  # np10 = {shape="BM.HPC2.36	", node_pool_size=5}
}
node_pool_image_id    = "none"
node_pool_name_prefix = "np"
node_pool_os          = "Oracle Linux"
node_pool_os_version  = "7.9"
worker_nsgs           = []
worker_type           = "private"

# upgrade of existing node pools
upgrade_nodepool        = true
node_pools_to_drain     = ["np1", "np2"]
nodepool_upgrade_method = "out_of_place"

# oke load balancers
enable_waf                   = false
load_balancers               = "both"
preferred_load_balancer      = "public"
#internal_lb_allowed_cidrs  = ["172.16.1.0/24", "172.16.2.0/24"] # By default, anywhere i.e. 0.0.0.0/0 is allowed
#internal_lb_allowed_ports  = [80, 443, "7001-7005"] # By default, only 80 and 443 are allowed
#public_lb_allowed_cidrs    = ["0.0.0.0/0"] # By default, anywhere i.e. 0.0.0.0/0 is allowed
#public_lb_allowed_ports    = [443,"9001-9002"] # By default, only 443 is allowed

# ocir
email_address    = ""
secret_id        = ""
secret_name      = "ocirsecret"
secret_namespace = "default"
username         = ""

# calico
enable_calico  = false
calico_version = "3.19"

# horizontal and vertical pod autoscaling
enable_metric_server = false
enable_vpa           = false
vpa_version          = 0.8

# service account
create_service_account               = false
service_account_name                 = ""
service_account_namespace            = ""
service_account_cluster_role_binding = ""

# freeform_tags
freeform_tags = {
  # vcn, bastion and operator freeform_tags are required
  # add more freeform_tags in each as desired
  vcn = {
    environment = "dev"
  }
  bastion = {
    access      = "public",
    environment = "dev",
    role        = "bastion",
    security    = "high"
  }
  operator = {
    access      = "restricted",
    environment = "dev",
    role        = "operator",
    security    = "high"
  }
}

# placeholder variable for debugging scripts. To be implemented in future
debug_mode = false