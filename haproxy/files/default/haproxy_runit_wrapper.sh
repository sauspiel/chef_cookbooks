#!/bin/bash


function on_exit()
{
  echo "killing $HAPROXY_PID"
  kill $HAPROXY_PID
  echo "exiting"
}

function on_reload()
{
  echo "Reloading haproxy"
  /usr/sbin/haproxy -D -f /etc/haproxy/haproxy.cfg -sf $HAPROXY_PID
  sleep 1
  NEW_HAPROXY_PID=`cat /var/run/haproxy/haproxy.pid`
  echo "Old pid is: $HAPROXY_PID New pid is: $NEW_HAPROXY_PID"
  HAPROXY_PID=$NEW_HAPROXY_PID
}

export HAPROXY_SUPERVISOR_PID=$$

trap on_exit EXIT
trap on_reload USR2 HUP

mkdir -p /var/run/haproxy
/usr/sbin/haproxy -D -f /etc/haproxy/haproxy.cfg

HAPROXY_PID=`cat /var/run/haproxy/haproxy.pid`

echo "supervisor pid: $HAPROXY_SUPERVISOR_PID haproxy pid: $HAPROXY_PID"

while kill -0 $HAPROXY_PID
do
  sleep 1
done