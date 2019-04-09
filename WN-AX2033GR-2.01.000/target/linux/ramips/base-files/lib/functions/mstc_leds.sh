#!/bin/sh

LED=$1
ACTION=$2
RALINK_GPIO_LED_INFINITY=4000
LEDS_DIR="/etc/leds.d"

led_on() {
	command=$(/sbin/uci -c $LEDS_DIR get leds.$1.command)
	gpio_num=$(/sbin/uci -c $LEDS_DIR get leds.$1.gpio_num)
	active_low=$(/sbin/uci -c $LEDS_DIR get leds.$1.active_low)

	[ -z "${command}" ] && [ -z "${gpio_num}" ]  && [ -z "${active_low}" ] && {
			echo "uci led_on{$1} setting is not exist!!"				
			return 1
	}
	[ $gpio_num -eq 0 ] && return 1
	
	$command l $gpio_num $RALINK_GPIO_LED_INFINITY 0 0 0 1 $active_low
}
led_off() {
	command=$(/sbin/uci -c $LEDS_DIR get leds.$1.command)
	gpio_num=$(/sbin/uci -c $LEDS_DIR get leds.$1.gpio_num)
	active_low=$(/sbin/uci -c $LEDS_DIR get leds.$1.active_low)

	[ -z "${command}" ] && [ -z "${gpio_num}" ]  && [ -z "${active_low}" ] && {
			echo "uci led_off{$1} setting is not exist!!"				
			return 1
	}
	[ $gpio_num -eq 0 ] && return 1

	$command l $gpio_num 0 $RALINK_GPIO_LED_INFINITY 0 0 1 $active_low
}
led_timer() {
	command=$(/sbin/uci -c $LEDS_DIR get leds.$1.command)
	gpio_num=$(/sbin/uci -c $LEDS_DIR get leds.$1.gpio_num)
	active_low=$(/sbin/uci -c $LEDS_DIR get leds.$1.active_low)
	delayon=$(/sbin/uci -c $LEDS_DIR get leds.$1.delayon)
	delayoff=$(/sbin/uci -c $LEDS_DIR get leds.$1.delayoff)
	[ -z "${command}" ] && [ -z "${gpio_num}" ]  && [ -z "${active_low}" && [ -z "${delayon}" && [ -z "${delayoff}" ] && {
			echo "uci led_timer{$1} setting is not exist!!"				
			return 1
	}
	[ $gpio_num -eq 0 ] && return 2

	[ -n "$2" ] && [ -n "$3" ] && {
		delayon=$2
		delayoff=$3
	}

	on=`expr $delayon / 100`
	off=`expr $delayoff / 100`
	#gpio l <gpio> <on> <off> <blinks> <rests> <times> <active_low>
	#MSTC MBA Sean, blinks set to 1: blinks means do rest after blink <blinks> time
	#rests set to 0: delay after a cycle, we don't need that, set to 0
	$command l $gpio_num $on $off 1 0 $RALINK_GPIO_LED_INFINITY $active_low
}

led_morse() {
	command=$(/sbin/uci -c $LEDS_DIR get leds.$1.command)
	gpio_num=$(/sbin/uci -c $LEDS_DIR get leds.$1.gpio_num)
	active_low=$(/sbin/uci -c $LEDS_DIR get leds.$1.active_low)
	delayon=$(/sbin/uci -c $LEDS_DIR get leds.$1.delayon)
	delayoff=$(/sbin/uci -c $LEDS_DIR get leds.$1.delayoff)
	times=`expr $2 + $2`
	
	[ -z "${command}" ] && [ -z "${gpio_num}" ]  && [ -z "${active_low}" ] && {
			echo "uci led_timer{$1} setting is not exist!!"				
			return 1
	}
	[ $gpio_num -eq 0 ] && return 1

	on=`expr $delayon / 100`
	off=`expr $delayoff / 100`
	$command l $gpio_num $on $off $times $times $RALINK_GPIO_LED_INFINITY $active_low
}

status_led_set_timer() {
	led_timer $status_led "$1" "$2"
}

status_led_on() {
	led_on $status_led
}

status_led_off() {
	led_off $status_led
}

status_led_blink_slow() {
	led_timer $status_led 1000 1000
}

status_led_blink_fast() {
	led_timer $status_led 100 100
}

status_led_blink_preinit() {
	[ -n "$status_led2" ] && $status_led2
}

status_led_blink_failsafe() {
	exit 0
}
