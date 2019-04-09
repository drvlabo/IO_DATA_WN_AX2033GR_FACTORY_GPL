#!/bin/sh
. /lib/functions.sh


platform_md5_password_gen()
{
	APFPASSWDCONF="/tmp/apfpasswd"

	md5_password=`uci get account.http.password 2>/dev/null`

	APFPass=:admin:$md5_password:

	echo $APFPass > $APFPASSWDCONF
}


apf_password_input2md5()
{
	account=`uci get account.http.user 2>/dev/null`
	realm=`uci get account.http.realm 2>/dev/null`
	input_pass=$1
	
#	echo $input_pass
#	echo $account $realm $input_pass
	
	cmd=`echo -n $account:$realm:$input_pass | md5sum | cut -b -32`
	
#	md5_password=`uci get account.http.password`
#	echo $md5_password

	echo $cmd
}

#####################################################
# @brief Main entry 
#####################################################

case "$1" in
	md5_password)
		platform_md5_password_gen
	;;
	apf_password_input)
		apf_password_input2md5 $2
	;;
	*)
		echo "[APFPassGen Script] Usage: $0 { md5_password | apf_password_input }"
		ret=1
	;;
esac

exit
