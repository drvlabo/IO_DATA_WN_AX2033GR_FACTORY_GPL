#!/bin/sh

insmod /lib/modules/ralink/hw_nat.ko

vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`

for vif in $vifs; do
	local netif
	netif=`uci -q get ${vif}.ifname`
	iwpriv $netif set hw_nat_register=1
	echo "register $netif in hw_nat !!!!!"
done
