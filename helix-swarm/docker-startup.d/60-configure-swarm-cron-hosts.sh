#!/bin/bash

set -e

# Worker script should access Swarm using localhost.
echo "localhost:80" > /opt/perforce/etc/swarm-cron-hosts.conf
