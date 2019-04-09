#!/bin/sh
. /lib/functions.sh

config_load network
config_get mode "wan" "mode"
config_get ether_wan "wan" "ifname"
config_get wan_proto "wan" "proto"
config_get lan_addr "lan" "ipaddr"
config_get lan_mask "lan" "netmask"
ether_lan=br-lan
config_load system
config_get http_redirect_enable "easysetup" "http_redirect_enable"

lan_wan_same_subnet_check()
{
	if [ ! -z $ether_wan ] && [ ! -z $wan_proto ] ; then
		if [ "$wan_proto" == "pppoe" ] ; then
			wan_itf=pppoe-wan
		else
			wan_itf=$ether_wan
		fi
	else
		echo "check wan itf failed" > /dev/null
	fi

	lan_1=`echo $lan_addr | awk -F. '{print $1}'`
	lan_2=`echo $lan_addr | awk -F. '{print $2}'`
	lan_3=`echo $lan_addr | awk -F. '{print $3}'`
	lan_4=`echo $lan_addr | awk -F. '{print $4}'`

	lan_mask_1=`echo $lan_mask | awk -F. '{print $1}'`
	lan_mask_2=`echo $lan_mask | awk -F. '{print $2}'`
	lan_mask_3=`echo $lan_mask | awk -F. '{print $3}'`
	lan_mask_4=`echo $lan_mask | awk -F. '{print $4}'`

	wan_addr=`ifconfig $wan_itf | grep 'inet addr:' | sed 's/^.*addr://g' | awk '{print $1}'`

	wan_1=`echo $wan_addr | awk -F. '{print $1}'`
	wan_2=`echo $wan_addr | awk -F. '{print $2}'`
	wan_3=`echo $wan_addr | awk -F. '{print $3}'`
	wan_4=`echo $wan_addr | awk -F. '{print $4}'`

	wan_mask=`ifconfig $wan_itf | grep 'inet addr:' | awk '{print $4}' | sed -e 's/Mask://'`

	wan_mask_1=`echo $wan_mask | awk -F. '{print $1}'`
	wan_mask_2=`echo $wan_mask | awk -F. '{print $2}'`
	wan_mask_3=`echo $wan_mask | awk -F. '{print $3}'`
	wan_mask_4=`echo $wan_mask | awk -F. '{print $4}'`

	if [ -z "$lan_addr" ] || [ -z "$lan_mask" ] || [ -z "$wan_addr" ] || [ -z "$wan_mask" ] ; then
		return 1
	fi

	lan_cal=$(( lan_1 & lan_mask_2 ))$(( lan_2 & lan_mask_2 ))$(( lan_3 & lan_mask_3 ))$(( lan_4 & lan_mask_4 ))

	wan_cal=$(( wan_1 & wan_mask_2 ))$(( wan_2 & wan_mask_2 ))$(( wan_3 & wan_mask_3 ))$(( wan_4 & wan_mask_4 ))

	if [ "$lan_cal" == "$wan_cal" ] ; then
		echo "wan and lan in the same subnet" > /dev/null
		return 1
	else
		echo "wan and lan in diff subnet" > /dev/null
		return 0
	fi
}

http_redirect_disable()
{
	if [ -f "/tmp/do_http_redirect" ] || [ "$1" == "update" ] ; then
		rm -rf /tmp/do_http_redirect
		mkdir -p /etc/httpredirect
		echo "" > /etc/httpredirect/firewall.include
		/etc/init.d/firewall restart
		/etc/init.d/dnsmasq restart
	fi
}

http_redirect_rule()
{
	cmd="iptables -t nat -A PREROUTING  -i br-lan ! -d $lan_addr -p tcp --dport 80 -j DNAT --to-destination $lan_addr:80"

	if [ ! -f "/tmp/do_http_redirect" ] || [ "$1" == "update" ] ; then
		touch "/tmp/do_http_redirect"
		mkdir -p /etc/httpredirect
		echo $cmd > /etc/httpredirect/firewall.include
		/etc/init.d/firewall restart
		/etc/init.d/dnsmasq restart
	fi
}


if [ "$mode" == "router" ] && [ "$http_redirect_enable" == "1" ] && [ ! -f "/tmp/wan_proto_change" ] && [ "$1" != "disable" ]; then
	portLinkStat=`switch reg r 3008 | sed 's/^.*=//g' | awk '{print substr($0, length($0), length($0))}'`
	if [ "$portLinkStat" == "1" -o "$portLinkStat" == "3" -o "$portLinkStat" == "5" -o "$portLinkStat" == "7" -o "$portLinkStat" == "9" -o "$portLinkStat" == "b" -o "$portLinkStat" == "d" -o "$portLinkStat" == "f" ]; then
		portLinked="1"
	fi
	if [ ! -z $ether_lan ] && [ ! -z $ether_wan ] && [ "$portLinked" == "1" ] ; then
		lan_wan_same_subnet_check
		ret_val=`echo $?`
		if [ "$ret_val" == "0" ] ; then
			if [ "$wan_proto" == "pppoe" ] ; then
				inetchk -woi
			else
				inetchk -i $ether_wan
			fi
			ret_val=`echo $?`
			if [ "$ret_val" = "1" ] ; then
				echo "network is ok" > /dev/null
				http_redirect_disable $1
			else
				http_redirect_rule $1
			fi
		else
			http_redirect_rule $1
		fi
	else
		echo "wan port not link" > /dev/null
		http_redirect_rule $1
	fi
fi

if [ "$1" == "disable" ]; then
	http_redirect_disable update
fi
