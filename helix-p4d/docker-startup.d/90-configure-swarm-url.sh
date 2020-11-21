#!/bin/bash

set -e

# check if swarm url is set
if [[ -z "${SWARM_URL}" ]]; then
    exit 0
fi

# update property
echo "Setting P4.Swarm.URL to ${SWARM_URL}"
p4 property -a -n 'P4.Swarm.URL' -v "${SWARM_URL}" 1>/dev/null
