FROM ubuntu:18.04


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
        helix-p4d \
        helix-swarm-triggers \
 && rm -rf /var/lib/apt/lists/*


ENV P4PORT                  ssl:1666
ENV P4USER                  p4admin
ENV P4PASSWD                P@ssw0rd

ENV P4NAME                  master
ENV P4ROOT                  /data/${P4NAME}/root
ENV P4SSLDIR                ${P4ROOT}/ssl


COPY docker-entrypoint.sh /
COPY docker-startup.d/    /docker-startup.d/
COPY p4-depots            /p4-depots
COPY p4-groups            /p4-groups
COPY p4-passwd            /p4-passwd
COPY p4-protect           /p4-protect
COPY p4-typemap           /p4-typemap
COPY p4-users             /p4-users

HEALTHCHECK --interval=5s --timeout=1s --start-period=15s \
    CMD p4 info

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD gosu perforce p4d -p "${P4PORT}"
