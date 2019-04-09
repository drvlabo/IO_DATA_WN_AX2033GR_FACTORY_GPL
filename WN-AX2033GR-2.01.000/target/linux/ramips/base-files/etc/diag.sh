#!/bin/sh
# Copyright (C) 2010-2013 OpenWrt.org

. /lib/functions/mstc_leds.sh
. /lib/ramips.sh

get_status_led() {
	case $(ramips_board_name) in
	*) 
		status_led="power"
		;;
	esac
}
# __MSTC__, Vincent: LED UCI cfg is not avaliable here, hard code here by MODEL
get_status2_led() {
	case $(ramips_model_name) in
	*"MiCAP-3340C"*) 
		status_led2="gpio l 9 1 1 1 1 4000 1"
		;;
	esac
}

set_state() {
	get_status_led
	get_status2_led

	case "$1" in
	preinit)
		status_led_blink_preinit
		;;
	failsafe)
		status_led_blink_failsafe
		;;
	done)
		status_led_on
		;;
	esac
}
