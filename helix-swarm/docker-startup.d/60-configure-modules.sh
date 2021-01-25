#!/bin/bash

set -e

# enable mod_rewrite
a2enmod rewrite 1>/dev/null

# configure mod_ssl
if [[ "${SWARM_SSL_ENABLE}" == "true" ]]; then
    a2enmod ssl 1>/dev/null
else
    a2dismod ssl 1>/dev/null
fi
