#!/usr/bin/python3
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

import os,sys,base64,subprocess,re

import oci
          
compartment_id  = '${compartment_id}'
region          = '${region}'
secret_id       = '${secret_id}'
email_address   = '${email_address}'
region_registry = '${region_registry}'
tenancy_name    = '${tenancy_name}'
username        = '${username}'

signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

identity_client = oci.identity.IdentityClient(config={}, signer=signer)

secret_client = oci.secrets.SecretsClient(config={'region': region}, signer=signer)

def read_secret_value(secret_client, secret_id):
    response = secret_client.get_secret_bundle(secret_id)

    base64_Secret_content = response.data.secret_bundle_content.content
    base64_secret_bytes = base64_Secret_content.encode('ascii')
    base64_message_bytes = base64.b64decode(base64_secret_bytes)
    secret_content = base64_message_bytes.decode('ascii')

    return secret_content


secret_content = read_secret_value(secret_client, secret_id=secret_id)
secret_content = re.escape(secret_content)


command = "kubectl -n default delete secret ocirsecret"
os.system(command)

command1 = ("kubectl create secret docker-registry ocirsecret -n default --docker-server=${region_registry} --docker-username=${tenancy_name}/${username} --docker-email=${email_address} --docker-password=%s" % secret_content)

subprocess.call(["/bin/bash" , "-c" , command1])
