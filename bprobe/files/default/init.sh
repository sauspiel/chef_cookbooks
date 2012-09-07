#!/bin/sh -e
### BEGIN INIT INFO
# Provides:          bprobe
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Should-Start:      $all
# Should-Stop:       $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop bprobe
# Description:       Start/stop bprobe
### END INIT INFO

PATH="/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin"

[ -x /usr/local/bin/bprobe ] || exit 0

. /lib/lsb/init-functions

[ -f /etc/bprobe/bprobe.defaults ] && . /etc/bprobe/bprobe.defaults
[ -f /etc/default/bprobe ] && . /etc/default/bprobe

INTERFACE_LINE=
if [ "$INTERFACES" != "" ]; then
  for iface in $INTERFACES; do
    INTERFACE_LINE="$INTERFACE_LINE -i $iface"
  done
fi

DAEMON_OPTS="--tls-key $TLS_KEY\
             --tls-ca $TLS_CA --tls-cert $TLS_CERT $INTERFACE_LINE -n $COLLECTOR --flow-version 10\
             -p 1/1/1/1/0/1 -w $FLOW_MAP_SIZE --pid-file $PIDFILE -e $FLOW_PAUSE --syslog bprobe -b 2 -G
             --streaming --no-promisc"

case "$1" in
start)
	log_daemon_msg "Starting Boundary flow meter" "bprobe"
	if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
		log_progress_msg "apparently already running"
		log_end_msg 0
		exit 0
	fi
	if start-stop-daemon --start --quiet \
		--pidfile $PIDFILE --exec /usr/local/bin/bprobe -- $DAEMON_OPTS
	then
		rc=0
		sleep 1
		if ! kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
			log_failure_msg "bprobe daemon failed to start"
			rc=1
		fi
	else
		rc=1
	fi
	if [ $rc -eq 0 ]; then
		log_end_msg 0
	else
		log_end_msg 1
		rm -f $PIDFILE
	fi
	;;
stop)
	log_daemon_msg "Stopping Boundary flow meter" "bprobe"
	start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE --signal INT
	log_end_msg $?
	rm -f $PIDFILE
	;;

status)
        log_daemon_msg "Checking to see if Boundary flow meter is running" "bprobe"
        fail=0
        pid=

        # does the pidfile even exist?
        if [ ! -f "$PIDFILE" ]; then
                fail=1
        else
                pid=`cat $PIDFILE`
        fi

        if [ $fail -eq 0 ]; then
          # is the pid non zero?
          if [ -z $pid ]; then
                fail=1
          # is there an entry in proc for this pid?
          elif [ ! -d /proc/$pid ]; then
                fail=1
          # does the command line start with /usr/local/bin/bprobe?
          elif [ `cat /proc/$pid/cmdline | tr "\000" "\n" | head -n 1` != "/usr/local/bin/bprobe" ]; then
                fail=1
          fi
        fi

        # if we still haven't failed yet...
        if [ $fail -eq 0 ]; then
                # check if the meter is connected to the collector
                netstat -an | grep 4740 | grep ESTABLISHED > /dev/null 2>&1
                if [ $? -ne 0 ]; then
                        fail=2
                fi
        fi

        if [ $fail -eq 1 ]; then
                log_failure_msg "bprobe daemon is not running"
        elif [ $fail -eq 2 ]; then
                log_failure_msg "bprobe daemon is running but not connected to Boundary! Try restarting it."
                log_end_msg 2
        elif [ $fail -eq 0 ]; then
                log_success_msg "bprobe daemon is running and connected to Boundary."
        fi
        ;;

force-reload|restart)
	log_daemon_msg "Restarting Boundary flow meter" "bprobe"
	if [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
		start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE --signal INT || true
		sleep 1
	else
		log_warning_msg "bprobe daemon not running, attempting to start"
		rm -f $PIDFILE
	fi
        if start-stop-daemon --start --quiet \
                --pidfile $PIDFILE --exec /usr/local/bin/bprobe -- $DAEMON_OPTS
	then
		rc=0
		sleep 1
		if ! kill -0 $(cat $PIDFILE) >/dev/null 2>&1; then
			log_failure_msg "bprobe daemon failed to start"
			rc=1
		fi
	else
		rc=1
	fi
	if [ $rc -eq 0 ]; then
		log_end_msg 0
	else
		log_end_msg 1
		rm -f $PIDFILE
	fi
	;;
	
*)
	echo "Usage: /etc/init.d/bprobe {start|stop|restart|force-reload}"
	exit 1
	;;
esac

exit 0