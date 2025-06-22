ARG HELIX_P4D_VERSION=2025.1
ARG HELIX_SWARM_VERSION=2025.1


FROM ubuntu:24.04 AS helix-base


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


ARG HELIX_P4D_VERSION
ENV HELIX_P4D_VERSION=${HELIX_P4D_VERSION}
ARG HELIX_SWARM_VERSION
ENV HELIX_SWARM_VERSION=${HELIX_SWARM_VERSION}

RUN curl -s -L https://package.perforce.com/perforce.pubkey | gpg --dearmor > /etc/apt/trusted.gpg.d/perforce.gpg \
 && apt-add-repository -y "deb http://package.perforce.com/apt/ubuntu $(lsb_release -sc) release" \
 && rm -rf /var/lib/apt/lists/*


FROM helix-base AS helix-swarm

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
        helix-swarm="${HELIX_SWARM_VERSION}"-* \
        redis-server \
        supervisor \
 && rm -rf /var/lib/apt/lists/*


ENV PATH=/opt/perforce/bin:${PATH}

ENV P4PORT=ssl:p4d:1666
ENV P4USER=p4admin
ENV P4PASSWD=P@ssw0rd


COPY etc /etc
COPY opt /opt
COPY docker-entrypoint.sh /
COPY docker-startup.d/    /docker-startup.d/

HEALTHCHECK --interval=1m --timeout=5s --start-period=30s \
    CMD supervisorctl status all

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--configuration", "/etc/supervisor/supervisord.conf"]
