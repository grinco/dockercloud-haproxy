#!/bin/sh
/usr/sbin/rsyslogd
nohup /usr/local/bin/dockercloud-haproxy &
tail -f /var/log/haproxy.log
