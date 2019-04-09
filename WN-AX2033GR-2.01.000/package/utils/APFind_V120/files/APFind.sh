#!/bin/sh /etc/rc.common

START=99

APF="/usr/sbin/APFind -c /etc/APFind.conf"
APFPID=/tmp/run/APFind.pid

restart() {
	$0 stop
	sleep 1
	$0 start
}

stop(){
	echo "Shutting down APFind: "
	/bin/kill `cat $APFPID`  
}

start(){
	echo "Starting APFind: "
	$APF
}

start_service() {
	start
}

stop_service() {
	stop
}

reload_service() {
    restart
}

boot() {
    start
}

