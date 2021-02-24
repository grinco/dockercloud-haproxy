FROM ubuntu:20.04
LABEL maintainer="marcelo.ochoa@gmail.com"

COPY . /haproxy-src
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y haproxy python2 curl && \
    curl https://bootstrap.pypa.io/2.7/get-pip.py --output get-pip.py && python2 get-pip.py && \
    cp /haproxy-src/reload.sh /reload.sh && \
    cd /haproxy-src && \
    pip install -r requirements.txt && \
    pip install . && \
    apt purge -y build-essential python-all-dev linux-libc-dev libgcc-7-dev && \
    apt autoremove -y && apt install -y python2 && \
    apt clean && rm -rf /var/lib/apt/lists/* && \
    rm -rf "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'`

ENV RSYSLOG_DESTINATION=127.0.0.1 \
    MODE=http \
    BALANCE=roundrobin \
    MAXCONN=4096 \
    OPTION="redispatch, httplog, dontlognull, forwardfor" \
    TIMEOUT="connect 5000, client 50000, server 50000" \
    STATS_PORT=1936 \
    STATS_AUTH="stats:stats" \
    SSL_BIND_OPTIONS=no-sslv3 \
    SSL_BIND_CIPHERS="ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA:DES-CBC3-SHA" \
    HEALTH_CHECK="check inter 2000 rise 2 fall 3" \
    NBPROC=1

EXPOSE 80 443 1936
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/usr/local/bin/dockercloud-haproxy"]
