#!/bin/bash

set -e

# install TLS certificate files
if [[ -n "${P4D_SSL_TLS_VERSION_MIN}" ]]; then
  echo "Running: set ssl.tls.version.min=${P4D_SSL_TLS_VERSION_MIN}"
  gosu perforce p4d -r "${P4ROOT}" -c "set ssl.tls.version.min=${P4D_SSL_TLS_VERSION_MIN}"
fi
if [[ -n "${P4D_SSL_TLS_VERSION_MAX}" ]]; then
  echo "Running: set ssl.tls.version.max=${P4D_SSL_TLS_VERSION_MAX}"
  gosu perforce p4d -r "${P4ROOT}" -c "set ssl.tls.version.max=${P4D_SSL_TLS_VERSION_MAX}"
fi
