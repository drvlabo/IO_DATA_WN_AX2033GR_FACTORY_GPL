#!/bin/sh

if [ "$#" -eq 1 ]; then
	sleep $1
else
	sleep 5
fi

reboot

