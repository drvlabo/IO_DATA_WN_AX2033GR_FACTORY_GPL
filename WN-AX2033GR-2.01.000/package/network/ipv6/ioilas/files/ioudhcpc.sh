#!/bin/sh

iodhcpevent $1 "$interface" "$ip" "$router" "$subnet" "$broadcast" "$domain" "$dns"

