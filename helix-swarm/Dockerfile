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


ENV P4PORT      ssl:p4d:1666
ENV P4SER       super
ENV P4PASSWD    P@ssw0rd


COPY etc /etc
COPY docker-entrypoint.sh /


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "--configuration", "/etc/supervisor/supervisord.conf"]

