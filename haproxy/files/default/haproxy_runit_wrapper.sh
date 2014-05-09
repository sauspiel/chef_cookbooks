#!/bin/sh
set -e

# start Unicorn in the background:
COMMAND="/usr/sbin/haproxy -D -f /etc/haproxy/haproxy.cfg"

`$COMMAND`

# for sig in USR2 TERM
# do
#   trap $COMMAND' -sf $(cat /var/run/haproxy/haproxy.pid)' $sig
# done

for sig in USR1 TTOU TTIN INT HUP QUIT PIPE
do
  trap 'kill -'$sig' $(cat /var/run/haproxy/haproxy.pid)' $sig
done

# loop forever while haproxy is running
while pkill -0 haproxy
do
   sleep 1
done