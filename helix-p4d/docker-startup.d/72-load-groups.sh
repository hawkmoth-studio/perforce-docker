#!/bin/bash

set -e

# check if groups need to be loaded
if [[ "${P4D_LOAD_GROUPS}" != "true" ]]; then
    exit 0
fi

# load all from /p4-groups
for GROUP_SPEC_FILE in /p4-groups/*.txt; do
    p4 group -i <<EOF
$(cat "${GROUP_SPEC_FILE}")
EOF
done
