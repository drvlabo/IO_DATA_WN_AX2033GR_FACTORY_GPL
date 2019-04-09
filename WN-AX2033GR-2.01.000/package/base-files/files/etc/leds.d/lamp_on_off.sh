#!/bin/sh
# Copyright (C) 2008 OpenWrt.org

mii_mgr -s -p 0 -r 13 -v 0x1f
mii_mgr -s -p 0 -r 14 -v 0x25	#LED0 Blinking Control Register
mii_mgr -s -p 0 -r 13 -v 0x401f
mii_mgr -s -p 0 -r 14 -v 0x0	#disable all blink event
	
lamp_status=`uci get system.lamp.led_light`
[ ! -z "$lamp_status" ] && [ "$lamp_status" = "0" ] && {
	mii_mgr -s -p 0 -r 13 -v 0x1f
	mii_mgr -s -p 0 -r 14 -v 0x24	#LED0 of all port
	mii_mgr -s -p 0 -r 13 -v 0x401f
	mii_mgr -s -p 0 -r 14 -v 0x4000	#turn off lights
	/sbin/mstc_led.sh power off
}
