#!/bin/bash

set -e

# check if trigger token should be installed
if [[ -z "${SWARM_TRIGGER_TOKEN}" ]]; then
    exit 0
fi

# create directory for tokens
export SWARM_TOKENS_DIRECTORY="${SWARM_DATA_DIR}/queue/tokens"
mkdir -pv "${SWARM_TOKENS_DIRECTORY}"

# for a trigger token to be valid, there must exist an empty file with trigger token name in tokens directory
touch "${SWARM_TOKENS_DIRECTORY}/${SWARM_TRIGGER_TOKEN}"
