#!/bin/bash

set -e


# link p4dctl service configuration file into /etc/perforce/
P4_CONF_DIR="/data/config"
if [[ ! -d "${P4_CONF_DIR}" ]]; then
    mkdir -pv "${P4_CONF_DIR}"
    cp -rvf "/etc/perforce"/* "${P4_CONF_DIR}/"
fi
# link docker volume directory to default perforce config location
mv /etc/perforce{,.orig}
ln -sv "${P4_CONF_DIR}" "/etc/perforce"


# setup p4 root and ssl directory paths
export P4ROOT="/data/${P4NAME}/root"
export P4SSLDIR="${P4ROOT}/ssl"

# create directories, set correct ownership
for d in "${P4ROOT}" "${P4SSLDIR}"; do
    mkdir -pv "${d}"
    chown -R perforce:perforce "${d}"
done


# run all scripts from /docker-startup.d
for f in /docker-startup.d/*.sh; do
    bash "${f}" || exit 1
done

# exec docker command
exec "$@"

