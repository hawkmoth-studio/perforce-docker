#!/bin/bash

set -e

# setup loop options
max_iterations=15
iterations=0

# skip waiting for p4d to start if required
if [[ "${SWARM_P4D_NOWAIT}" == "true" ]]; then
    exit 0
fi

# if p4d is ssl-enabled, we should use p4 trust to test for connection
if [[ "${P4PORT}" == "ssl:"* ]]; then
    P4_CHECK_CMD="p4 trust -y"
else
    P4_CHECK_CMD="p4 info"
fi

# enter wait loop
while true; do
    # test connection to p4d
    set +e
    __result=$(
        ${P4_CHECK_CMD} 2>&1
    )
    __p4_check_result=$?
    set -e

    # p4 exits with 0 when connection to server is successfully established
    # shellcheck disable=SC2181
    if [[ "${__p4_check_result}" == "0" ]]; then
        break
    fi
    # p4 issues "Connect to server failed" when server is not available (e.g. port is closed)
    #
    # if P4PORT is set to an incorrect value (e.g. not prefixed with ssl: for ssl-enabled p4d),
    # different error message is returned
    if [[ "${__result}" != *"Connect to server failed"* ]]; then
        echo "${__result}" 1>&2
        exit 1
    fi

    # check if iteration limit has been reached
    if [[ "${iterations}" -ge "${max_iterations}" ]]; then
        echo "Perforce server connection timeout." 1>&2
        exit 1
    fi

    # log to console
    echo "Waiting for perforce server to become available..."
    # increment iteration counter
    ((++iterations))
    # sleep
    sleep 1
done

# log to console
echo "Successfully connected to ${P4PORT}."
