 #!/bin/bash
# Copyright 2017, 2020, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

for node in $(cat drainlist.txt)
do 
  kubectl drain $node --force --ignore-daemonsets
  echo $node drained
done