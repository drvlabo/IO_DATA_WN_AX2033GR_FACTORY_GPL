#!/bin/sh
. /lib/functions.sh

LOG_FILE="/tmp/simple_log.log"
DEFAULT_LOG_LIMIT=2048

usage(){
	echo "usage : $1 [option] "
	echo "    option : "
	echo "        -w <message>    Append message into log"
	echo "        -r              Read log"
	echo "        -c              clean log"
	echo ""
}

write_log(){
	if [ ! -s ${LOG_FILE} ]; then
		echo "`date +"%b %d %T"` [SYSTEM]: $*" >> ${LOG_FILE}
	else
		local log_lines=`wc -l ${LOG_FILE} | sed 's/ .*//'`

		config_load system
		config_get log_limit simplelog limit

		if [ "${log_limit}" == "" ]; then
			log_limit=${DEFAULT_LOG_LIMIT}
		fi

		if [ ${log_lines} -ge ${log_limit} ]; then
			de_line=$(( ${log_lines} - ${log_limit} + 1 ))
			sedCmd="1,${de_line}!{P;N;D;};N;ba"
			sed -n -e :a -e ${sedCmd} -i ${LOG_FILE}
		fi

		sed -e "1i `date +"%b %d %T"` [SYSTEM]: $*" -i ${LOG_FILE}
	fi
}

read_log(){
	cat ${LOG_FILE}
}

clean_log(){
	rm -rf ${LOG_FILE}
	touch ${LOG_FILE}
}

if [ ! -f ${LOG_FILE} ]; then
	touch ${LOG_FILE}
fi

case $1 in
	"-w")
		shift
		write_log $*
		;;
	"-r")
		read_log
		;;
	"-c")
		clean_log
		;;
	*)
		usage $0
		;;
esac

exit 0