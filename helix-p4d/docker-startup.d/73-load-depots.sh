#!/bin/bash

set -e

# check if depots need to be loaded
if [[ "${P4D_LOAD_DEPOTS}" != "true" ]]; then
    exit 0
fi

# load all from /p4-depots
for DEPOT_SPEC_FILE in /p4-depots/*.txt; do
    p4 depot -i <<EOF
$(cat "${DEPOT_SPEC_FILE}")
EOF
done
