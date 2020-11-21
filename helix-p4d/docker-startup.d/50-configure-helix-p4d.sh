#!/bin/bash

set -e

# check if p4d service is already configured
if gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
    echo "Starting p4d server in local-only mode..."

    # p4d running with localhost-only binding is used in other scripts (e.g. to setup triggers)
    gosu perforce p4dctl start "${P4NAME}" &>/dev/null

    # automatically trust self
    if [[ "${P4PORT}" == "ssl:"* ]]; then
        p4 trust -y &>/dev/null
    fi

    # login to local server
    echo "Logging in to local server..."
    echo "${P4PASSWD}" | p4 login 1>/dev/null

    exit 0
fi

# log to console
echo "Initializing p4d server..."

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
"${CONFIGURE_P4D_CMD[@]}" 1>/dev/null

# log to console
echo "p4d server initialization complete."
