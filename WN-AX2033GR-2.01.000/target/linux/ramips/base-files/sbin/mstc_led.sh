#!/bin/sh

. /lib/functions.sh
. /lib/functions/mstc_leds.sh

NAME=$1
ACTION=$2
DEALYON=$3
DEALYOFF=$4
COUNT=$3
do_led() {
	local cfg="$1"
	local name
	local color
	config_get name $cfg name
	config_get color $cfg color

	[ "$name" == $NAME -o "$NAME" == "all" -o "$NAME" == "$color" -a -c "/dev/gpio" ] && {
		[ "$ACTION" == "on" ] &&
			led_on $name
		[ "$ACTION" == "off" ] &&
			led_off $name
		[ "$ACTION" == "blink" ] &&
			led_timer $name $DEALYON $DEALYOFF
		[ "$ACTION" == "morse" ] &&
			led_morse $name $COUNT
		[ "$NAME" != "all" -a "$NAME" != "$color" ] && 
			exit 0
	}
}

[ "$ACTION" == "off" -o "$ACTION" == "on" -o "$ACTION" == "blink" -o "$ACTION" == "morse" ] &&
	[ -n "$NAME" ] &&{
		local UCI_CONFIG_DIR='/etc/leds.d'
		config_load leds
		config_foreach do_led led
		exit 1
	}
