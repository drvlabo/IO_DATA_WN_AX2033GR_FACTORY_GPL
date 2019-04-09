#!/bin/sh

http_access_config_path="/etc/lighttpd/conf.d/30-access.conf"

http_access_config_done="/tmp/http_access_config_done"

mode=`uci get network.wan.mode 2>/dev/null`

if [ "$mode" != "router" ] ; then
	if [ -f $http_access_config_path ]  && [ ! -f $http_access_config_done ] ; then
		echo "" >> $http_access_config_path
		echo \$HTTP[\"url\"] =~ \"/ezinet.htm\" { >> $http_access_config_path
		echo url.access-deny = \( \"\" \) >> $http_access_config_path
		echo } >> $http_access_config_path
		
		echo \$HTTP[\"url\"] =~ \"/ezinet_pre.htm\" { >> $http_access_config_path
		echo url.access-deny = \( \"\" \) >> $http_access_config_path
		echo } >> $http_access_config_path
		
		echo \$HTTP[\"url\"] =~ \"/cgi-bin/sec/\" { >> $http_access_config_path
		echo url.access-deny = \( \"\" \) >> $http_access_config_path
		echo } >> $http_access_config_path
		
		touch $http_access_config_done
	fi
fi
