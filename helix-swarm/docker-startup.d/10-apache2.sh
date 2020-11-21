#!/bin/bash

set -e

# define global server name to prevent apache2 warnings
cat <<EOF >/etc/apache2/sites-available/000-default.conf
ServerName  ${SWARM_HOST}
EOF

# enable default virtual host
a2ensite 000-default 1>/dev/null
