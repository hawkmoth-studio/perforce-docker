#!/bin/bash

set -e


# define global server name to prevent apache2 warnings
cat <<EOF >/etc/apache2/sites-available/000-default.conf
ServerName  ${SWARM_HOST}
EOF
# enable default virtual host
a2ensite 000-default 1>/dev/null


# run perforce configuration script if config.php does not exist
if [[ ! -f "/opt/perforce/swarm/data/config.php" ]]; then
    CONFIGURE_SWARM_CMD=("/opt/perforce/swarm/sbin/configure-swarm.sh")
    CONFIGURE_SWARM_CMD+=("--non-interactive")
    CONFIGURE_SWARM_CMD+=("--p4port" "${P4PORT}")
    CONFIGURE_SWARM_CMD+=("--swarm-user" "${SWARM_USER}")
    CONFIGURE_SWARM_CMD+=("--swarm-passwd" "${SWARM_PASSWD}")
    CONFIGURE_SWARM_CMD+=("--swarm-host" "${SWARM_HOST}")
    CONFIGURE_SWARM_CMD+=("--swarm-port" "${SWARM_PORT}")
    CONFIGURE_SWARM_CMD+=("--email-host" "${EMAIL_HOST}")
    if [[ "${SWARM_USER_CREATE}" == "true" ]]; then
        CONFIGURE_SWARM_CMD+=("--create-user")
        if [[ "${SWARM_GROUP_CREATE}" == "true" ]]; then
            CONFIGURE_SWARM_CMD+=("--create-group")
        fi
        CONFIGURE_SWARM_CMD+=("--super-user" "${P4USER}")
        CONFIGURE_SWARM_CMD+=("--super-passwd" "${P4PASSWD}")
    fi
    "${CONFIGURE_SWARM_CMD[@]}"
    # configure-swarm.sh starts apache2 automatically
    apachectl -k graceful-stop
fi


if [[ "${SWARM_SSL_ENABLE}" == "true" ]]; then
    if [[ -z "${SWARM_SSL_CERTIFICATE_FILE}" ]]; then
        SWARM_SSL_CERTIFICATE_FILE="/etc/ssl/certs/ssl-cert-snakeoil.pem"
        echo "WARNING! Using default certificate file: ${SWARM_SSL_CERTIFICATE_FILE}"
    fi
    if [[ -z "${SWARM_SSL_CERTIFICATE_KEY_FILE}" ]]; then
        SWARM_SSL_CERTIFICATE_KEY_FILE="/etc/ssl/private/ssl-cert-snakeoil.key"
        echo "WARNING! Using default certificate key file: ${SWARM_SSL_CERTIFICATE_KEY_FILE}"
    fi
    # enable mod_rewrite
    a2enmod rewrite 1>/dev/null
    # enable mod_ssl
    a2enmod ssl 1>/dev/null
    # write configuration file
    if [[ -z "${SWARM_SSL_REDIRECT_URL}" ]]; then
        SWARM_SSL_REDIRECT_URL="https://%{HTTP_HOST}%{REQUEST_URI}"
    fi
    cat <<EOF >/etc/apache2/sites-available/perforce-swarm-site.conf

# non-ssl virtual host
<VirtualHost *:${SWARM_PORT}>
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
<VirtualHost *:${SWARM_SSL_PORT:-443}>
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

    # disable mod_ssl
    a2dismod ssl 1>/dev/null
    # write apache virtual host configuration file
    cat <<EOF >/etc/apache2/sites-available/perforce-swarm-site.conf
# define global server name to prevent apache2 warnings
ServerName  ${SWARM_HOST}

# non-ssl virtual host
<VirtualHost *:${SWARM_PORT}>
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


# exec docker command
exec "$@"

