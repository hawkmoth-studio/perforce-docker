#!/bin/bash

set -e

export TYPEMAP_DIR="/typemaps"

# check if typemap needs to be loaded
if [[ -z "${P4D_TYPEMAP}" ]]; then
    exit 0
fi

# check if typemap exists
export P4D_TYPEMAP_PATH="${TYPEMAP_DIR}/${P4D_TYPEMAP}.txt"
if [[ ! -f "${P4D_TYPEMAP_PATH}" ]]; then
    echo "Unable to find typemap with id: ${P4D_TYPEMAP}" 1>&2
    echo "Available typemaps:"
    # shellcheck disable=SC2010
    for f in $(ls -1 "${TYPEMAP_DIR}" | grep '.*\.txt$' | sort); do
        echo "    ${f%.txt}"
    done
    exit 1
fi

# load typemap
echo "Loading typemap: ${P4D_TYPEMAP}"
p4 typemap -i <<EOF
Typemap:
$(cat "${P4D_TYPEMAP_PATH}")
EOF
