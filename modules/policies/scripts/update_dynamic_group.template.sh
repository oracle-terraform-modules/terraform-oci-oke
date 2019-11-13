#!/bin/bash
# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

oci iam dynamic-group update --dynamic-group-id ${dynamic_group_id} --matching-rule "${dynamic_group_rule}"
