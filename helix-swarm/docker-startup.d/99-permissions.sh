#!/bin/bash

set -e

# swarm data files must be owned by www-data
mkdir -pv "${SWARM_DATA_DIR}"
chown -R www-data:www-data "${SWARM_DATA_DIR}"
