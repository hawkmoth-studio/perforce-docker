FROM ubuntu:18.04


RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        curl \
        gosu \
        software-properties-common \
 && rm -rf /var/lib/apt/lists/*


RUN curl -s -L https://package.perforce.com/perforce.pubkey | apt-key add - \
 && apt-add-repository "deb http://package.perforce.com/apt/ubuntu $(lsb_release -sc) release" \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        helix-swarm \
        redis-server \
        supervisor \
 && rm -rf /var/lib/apt/lists/*


ENV P4PORT              ssl:p4d:1666
ENV P4SER               super
ENV P4PASSWD            P@ssw0rd

ENV SWARM_USER          ${P4USER}
ENV SWARM_PASSWD        ${P4PASSWD}
ENV SWARM_USER_CREATE   false
ENV SWARM_GROUP_CREATE  false

ENV SWARM_HOST          localhost
ENV SWARM_PORT          80

ENV SWARM_SSL_ENABLE    false
ENV SWARM_SSL_CERTIFICATE_FILE=
ENV SWARM_SSL_CERTIFICATE_KEY_FILE=

ENV EMAIL_HOST          localhost


COPY etc /etc
COPY docker-entrypoint.sh /
COPY docker-startup.d/    /docker-startup.d/

HEALTHCHECK --interval=5s --timeout=1s --start-period=15s \
    CMD supervisorctl status all

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--configuration", "/etc/supervisor/supervisord.conf"]

