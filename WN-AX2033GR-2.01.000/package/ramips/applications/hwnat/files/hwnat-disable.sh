#!/bin/sh

vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`

for vif in $vifs; do
	local netif
	netif=`uci -q get ${vif}.ifname`
	iwpriv $netif set hw_nat_register=0
	echo "unregister $netif in hw_nat !!!!!"
done

rmmod hw_nat.ko

