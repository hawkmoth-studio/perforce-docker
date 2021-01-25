FROM ubuntu:20.04


RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y upgrade \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        curl \
        gosu \
        software-properties-common \
        vim-tiny \
 && update-alternatives --install /usr/bin/editor editor /usr/bin/vi 1000 \
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


ENV PATH                /opt/perforce/bin:${PATH}

ENV P4PORT              ssl:p4d:1666
ENV P4USER              p4admin
ENV P4PASSWD            P@ssw0rd


COPY etc /etc
COPY docker-entrypoint.sh /
COPY docker-startup.d/    /docker-startup.d/

HEALTHCHECK --interval=1m --timeout=5s --start-period=30s \
    CMD supervisorctl status all

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf
