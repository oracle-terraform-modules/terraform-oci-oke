#!/bin/bash

# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

yum update --security

sed -i -e "s/autoinstall\s=\sno/autoinstall = yes/g" /etc/uptrack/uptrack.conf

uptrack-upgrade