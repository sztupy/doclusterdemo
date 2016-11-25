#!/bin/sh
service rsyslog start
touch /var/log/haproxy.log
tail -F /var/log/haproxy.log &
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
