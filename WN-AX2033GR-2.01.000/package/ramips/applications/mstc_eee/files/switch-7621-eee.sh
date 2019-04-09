#!/bin/sh

usage()
{
	echo "Usage:"
	echo "  $0 0 - Disable EEE"
	echo "  $0 1 - Enable EEE"
	exit 0
}

disable7530eee()
{
	#stop smart_speed
	killall -9 smart_speed
	smart_speed 0
}

enable7530eee()
{
	#excute smart_speed to enable EEE, auto link speed change and disable hw auto down shift
	killall -9 smart_speed
	smart_speed 1&
}

if [ "$1" = "0" ]; then
	disable7530eee
elif [ "$1" = "1" ]; then
	enable7530eee
else
	usage $0
fi
