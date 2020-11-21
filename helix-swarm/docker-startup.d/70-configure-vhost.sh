#!/bin/bash

set -e

if [[ "${SWARM_SSL_ENABLE}" == "true" ]]; then
    # write configuration file
    if [[ -z "${SWARM_SSL_REDIRECT_URL}" ]]; then
        SWARM_SSL_REDIRECT_URL="https://%{HTTP_HOST}%{REQUEST_URI}"
    fi
    cat <<EOF >/etc/apache2/sites-available/perforce-swarm-site.conf
# non-ssl virtual host
<VirtualHost *:80>
    ServerName  ${SWARM_HOST}
    ServerAlias localhost

    DocumentRoot "/opt/perforce/swarm/public"
    <Directory "/opt/perforce/swarm/public">
        AllowOverride All
        Require all granted
    </Directory>

    RewriteRule .*  ${SWARM_SSL_REDIRECT_URL}   [R]

    ErrorLog    "\${APACHE_LOG_DIR}/swarm.error_log"
    CustomLog   "\${APACHE_LOG_DIR}/swarm.access_log" common
</VirtualHost>

# ssl virtual host
<VirtualHost *:443>
    SSLEngine   on
    SSLCertificateFile      ${SWARM_SSL_CERTIFICATE_FILE}
    SSLCertificateKeyFile   ${SWARM_SSL_CERTIFICATE_KEY_FILE}

    ServerName  ${SWARM_HOST}
    ServerAlias localhost

    DocumentRoot "/opt/perforce/swarm/public"
    <Directory "/opt/perforce/swarm/public">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog    "\${APACHE_LOG_DIR}/swarm.error_log"
    CustomLog   "\${APACHE_LOG_DIR}/swarm.access_log" common
</VirtualHost>
EOF

else # SSL disabled

    # write apache virtual host configuration file
    cat <<EOF >/etc/apache2/sites-available/perforce-swarm-site.conf
# non-ssl virtual host
<VirtualHost *:80>
    ServerName  ${SWARM_HOST}
    ServerAlias localhost

    DocumentRoot "/opt/perforce/swarm/public"
    <Directory "/opt/perforce/swarm/public">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog    "\${APACHE_LOG_DIR}/swarm.error_log"
    CustomLog   "\${APACHE_LOG_DIR}/swarm.access_log" common
</VirtualHost>
EOF
fi

# enable perforce virtual host
a2ensite perforce-swarm-site 1>/dev/null
