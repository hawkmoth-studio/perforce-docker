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
        helix-p4d \
        helix-swarm-triggers \
 && rm -rf /var/lib/apt/lists/*


ENV P4PORT                  ssl:1666
ENV P4SER                   super
ENV P4PASSWD                P@ssw0rd

ENV P4NAME                  master
ENV P4D_CASE_SENSITIVE      0
ENV P4D_USE_UNICODE         0
ENV P4D_SECURITY            2

ENV INSTALL_SWARM_TRIGGER   false
ENV SWARM_TRIGGER_HOST      http://swarm
ENV SWARM_TRIGGER_TOKEN=


COPY docker-entrypoint.sh /
COPY docker-startup.d/    /docker-startup.d/

HEALTHCHECK --interval=5s --timeout=1s --start-period=15s \
    CMD p4 info

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD gosu perforce p4d -p "${P4PORT}"
