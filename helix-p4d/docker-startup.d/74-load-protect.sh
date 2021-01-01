#!/bin/bash

set -e

# check if protections need to be loaded
if [[ "${P4D_LOAD_PROTECTIONS}" != "true" ]]; then
    exit 0
fi

# check if there are any protection files
if [[ "$(ls -1 /p4-protect/*.txt 2>/dev/null | wc -l | awk '{ print $1 }')" == "0" ]]; then
    echo "No protection files could be found at /p4-protect!" 1>&2
    exit 1
fi

# load all from /p4-protect
p4 protect -i <<EOF
Protections:
$(cat /p4-protect/*.txt)
EOF
