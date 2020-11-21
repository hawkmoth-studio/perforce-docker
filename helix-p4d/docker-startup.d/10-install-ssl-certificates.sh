#!/bin/bash

set -e

# install TLS certificate files
if [[ -n "${P4D_SSL_CERTIFICATE_FILE}" ]]; then
    cp -Lvf "${P4D_SSL_CERTIFICATE_FILE}" "${P4SSLDIR}/certificate.txt"
    chmod 0600 "${P4SSLDIR}/certificate.txt"
fi
if [[ -n "${P4D_SSL_CERTIFICATE_KEY_FILE}" ]]; then
    cp -Lvf "${P4D_SSL_CERTIFICATE_KEY_FILE}" "${P4SSLDIR}/privatekey.txt"
    chmod 0600 "${P4SSLDIR}/privatekey.txt"
fi
