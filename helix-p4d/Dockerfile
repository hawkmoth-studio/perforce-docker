FROM ubuntu:18.04


RUN apt-get update \
 && apt-get -y install \
        gosu \
        software-properties-common \
        wget \
 && rm -rf /var/lib/apt/lists/*


RUN wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add - \
 && apt-add-repository "deb http://package.perforce.com/apt/ubuntu $(lsb_release -sc) release" \
 && apt-get update \
 && apt-get -y install \
        helix-p4d \
 && rm -rf /var/lib/apt/lists/*


COPY p4d-entrypoint.sh /
COPY p4d-run.sh /


ENV P4NAME      master
ENV P4ROOT      /data/${P4NAME}
ENV P4SSLDIR    ${P4ROOT}/root/ssl
ENV P4PORT      ssl:1666
ENV P4USER      p4admin
ENV P4PASSWD    P@ssw0rd
ENV P4CASE      0


ENTRYPOINT ["/p4d-entrypoint.sh"]
CMD ["/p4d-run.sh"]

