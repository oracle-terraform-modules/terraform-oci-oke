#!/usr/bin/env bash
# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Append a line to the current output file by resource kind + name
function appendFile(kind, name, line) {
  filename=output_directory"/"name"."tolower(kind)".yaml"
  printf("%s", line) >> filename
}

# Read a combined YAML file and split each resource by kind + name
BEGIN { yaml=""; k=""; n=""; }          # Initialize state variables
{
  line=$0
  # Detect record delimiter when state variables are populated
  if (index(line, "---") > 0 && k != "" && n != "") {
    appendFile(k, n, yaml)              # Output buffer on delimiter
    yaml=""; k=""; n=""                 # Reset state variables
    next                                # Skip to next record
  }
  yaml=yaml"\n"$0                       # Buffer the line to output
  match(line, /^kind: (.*)/)            # Match the Kubernetes "kind"
  if (RLENGTH>0) {
    k=substr(line, RSTART, RLENGTH)     # Select matching portion of line
    gsub(/^kind: /, "", k)              # Trim field name from line
    next                                # Skip to next record
  }
  match(line, /^  name: (.*)/)          # Match the Kubernetes "name"
  if (RLENGTH>0) {
    n=substr(line, RSTART, RLENGTH)     # Select matching portion of line
    gsub(/^(\ )+name: /, "", n)         # Trim field name from line
    next                                # Skip to next record
  }
}
END { appendFile(k, n, yaml); }         # Output final resource
