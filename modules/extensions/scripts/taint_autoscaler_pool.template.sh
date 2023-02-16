 #!/usr/bin/bash
# Copyright (c) 2022, Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

for NODE in $(taint_autoscaler_pool_list.txt); do
  kubectl taint nodes $NODE autoscaler=true:NoSchedule
  echo $NODE tainted with autoscaler=true:NoSchedule
done