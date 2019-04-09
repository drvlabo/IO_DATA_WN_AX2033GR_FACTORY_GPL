#!/bin/bash

GPIO_NUM=$1
ACTIVE_LOW=$2
MIN=$3
MAX=$4

ps | pgrep btnCbkd | awk '{print "kill -9 " $0}' | sh
eval btnCbkd reset_led $GPIO_NUM $ACTIVE_LOW $MIN $MAX & 