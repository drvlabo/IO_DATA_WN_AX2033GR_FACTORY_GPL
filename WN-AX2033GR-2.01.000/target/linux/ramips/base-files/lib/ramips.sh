#!/bin/sh
#
# Copyright (C) 2010-2013 OpenWrt.org
#

RAMIPS_BOARD_NAME=
RAMIPS_MODEL=

ramips_board_detect() {
	local machine
	local name
	machine=$(cat /proc/cpuinfo | grep -i MT76)
	case $machine in
		*"MT7620"*)
			name="MT7620"
			;;
		*"MT7621"*)
			name="MT7621"
			;;
		*"MT7628"*)
			name="MT7628"
			;;
		*"MT7688"*)
			name="MT7688"
			;;
		*"MT7623"*)
			name="MT7623"
			;;
		*) # actually this is *NOT* acceptable.
			name="generic"
			;;
	esac

	local model
	model=$(cat /etc/openwrt_release | grep -i DISTRIB_PRODUCT | sed 's/^DISTRIB_PRODUCT=//')
	case $model in
		*"MiCAP-3340C"* | *"WN-AX2033GR"*)
			model="MiCAP-3340C"
			;;
		*) # actually this is *NOT* acceptable.
			model="mtk-apsoc-demo"
			;;
	esac

	[ -z "$RAMIPS_BOARD_NAME" ] && RAMIPS_BOARD_NAME="$name"
	# __MSTC__, Vincent: define customer models here
	[ -z "$RAMIPS_MODEL" ] && RAMIPS_MODEL="$model"

	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"

	echo "$RAMIPS_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$RAMIPS_MODEL" > /tmp/sysinfo/model
}

ramips_board_name() {
	local name

	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}


ramips_model_name() {
	local name

	[ -f /tmp/sysinfo/model ] && name=$(cat /tmp/sysinfo/model)
	[ -z "$name" ] && name="unknown"

	echo "$name"
}


