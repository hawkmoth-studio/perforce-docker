#!/bin/bash

set -e

# check if typemaps needs to be loaded
if [[ "${P4D_LOAD_TYPEMAPS}" != "true" ]]; then
    exit 0
fi

# check if there are any typemap files
if [[ "$(ls -1 /p4-typemap/*.txt 2>/dev/null | wc -l | awk '{ print $1 }')" == "0" ]]; then
    echo "No typemap files could be found at /p4-typemap!" 1>&2
    exit 1
fi

# load all from /p4-typemap
p4 typemap -i <<EOF
Typemap:
$(cat /p4-typemap/*.txt)
EOF
