#!/bin/bash

set -e

# check if p4d service is configured
if gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
    exit 0
fi

# configure p4d server
CONFIGURE_P4D_CMD=("/opt/perforce/sbin/configure-helix-p4d.sh")
CONFIGURE_P4D_CMD+=("${P4NAME}")
CONFIGURE_P4D_CMD+=("-n")
CONFIGURE_P4D_CMD+=("-p" "${P4PORT}")
CONFIGURE_P4D_CMD+=("-r" "/data/${P4NAME}")
CONFIGURE_P4D_CMD+=("-u" "${P4USER}")
CONFIGURE_P4D_CMD+=("-P" "${P4PASSWD}")
if [[ "${P4D_CASE_SENSITIVE}" == "true" ]]; then
    CONFIGURE_P4D_CMD+=("--case" "0")
else
    CONFIGURE_P4D_CMD+=("--case" "1")
fi
if [[ "${P4D_USE_UNICODE}" == "true" ]]; then
    CONFIGURE_P4D_CMD+=("--unicode")
fi
# run configure script
"${CONFIGURE_P4D_CMD[@]}"
# configure-helix-p4d.sh starts p4d in background by default
gosu perforce p4dctl stop "${P4NAME}"
