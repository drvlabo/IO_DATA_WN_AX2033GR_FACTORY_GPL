#!/bin/bash

GPIO_NUM=$1
ACTIVE_LOW=$2
MIN=$3
MAX=$4
REPEATER_MODE="0"
HAVE_WPS_COPY="0"

WAN_MODE=`uci show network | grep network.wan.mode | sed -n "s/network.wan.mode=//gp"`

if [ "$WAN_MODE" == "repeater" ]; then
	REPEATER_MODE="1"
fi

#MSTC MBA Sean, check if wps copy exist
OUT=`uci -c /etc/buttons.d/ show buttons.wps | grep wps_copy`

if [ "$OUT" != "" ];then
   HAVE_WPS_COPY="1"
fi

#MSTC MBA Sean, check if wps is enable or not
WPS_ENABLE=`uci show wireless | grep wps_enable=1`

if [ "$WPS_ENABLE" != "" -o "$REPEATER_MODE" == "1" ];then
	ps | pgrep btnCbkd | awk '{print "kill -9 " $0}' | sh
	eval btnCbkd wps_led $GPIO_NUM $ACTIVE_LOW $MIN $MAX $REPEATER_MODE $HAVE_WPS_COPY& 
fi

