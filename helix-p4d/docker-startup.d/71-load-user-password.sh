#!/bin/bash

set -e

# check if users need to be loaded
if [[ "${P4D_LOAD_USER_PASSWORDS}" != "true" ]]; then
    exit 0
fi

# load all from /p4-passwd
for PASSWD_FILE in /p4-passwd/*.txt; do
    USER_NAME="$(basename "${PASSWD_FILE}")"
    USER_NAME="${USER_NAME%.txt}"
    p4 passwd "${USER_NAME}" <<EOF
$(cat "${PASSWD_FILE}")
$(cat "${PASSWD_FILE}")
EOF
done
