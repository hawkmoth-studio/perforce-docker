#!/bin/bash

set -e

# check if users need to be loaded
if [[ "${P4D_LOAD_USERS}" != "true" ]]; then
    exit 0
fi

# load all from /p4-users
for USER_SPEC_FILE in /p4-users/*.txt; do
    p4 user -i -f <<EOF
$(cat "${USER_SPEC_FILE}")
EOF
done
