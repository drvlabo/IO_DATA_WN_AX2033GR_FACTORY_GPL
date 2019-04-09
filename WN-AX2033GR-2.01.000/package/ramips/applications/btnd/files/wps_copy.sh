echo "gpio btn wps!"

vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`

#MBA Sean, default is off
wps_2g_wps_enable="0"
wps_5g_wps_enable="0"

if_2g_disable="0"
if_5g_disable="0"

num_2g_vifs=0
num_5g_vifs=0

REPEATER_MODE=`uci show network | grep network.wan.mode | sed -n "s/network.wan.mode=//gp"`

if [ "$REPEATER_MODE" == "repeater" ]; then
	echo "repeater mode, do not trigger 3 seconds wps button event"
	exit 1
fi

for vif in $vifs; do
        device=`uci -q get ${vif}.device`
		
		case "$device" in
            mt7620 | mt7602e | mt7603e | mt7628 | mt7688 | mt7615e2 )
				wps_2g_wps_enable=`uci -q get wireless.${device}.wsc_confmode`
				#MSTC MBA Sean, only check first interface is disable or not 
				if [ $num_2g_vifs == 0 ]; then
					if_2g_disable=`uci -q get ${vif}.disabled`
					num_2g_vifs=`expr $num_2g_vifs + 1`
				fi
                ;;
            mt7610e | mt7612e | mt7615e5)
				wps_5g_wps_enable=`uci -q get wireless.${device}.wsc_confmode`
				#MSTC MBA Sean, only check first interface is disable or not 
				if [ $num_5g_vifs == 0 ]; then
					if_5g_disable=`uci -q get ${vif}.disabled`
					num_5g_vifs=`expr $num_5g_vifs + 1`
				fi
                ;;
            * )
                echo "device $device not recognized!! " >>/tmp/wifi.log
                ;;
        esac            
		
done

if [ "$if_2g_disable" != "1" ]; then
	#MSTC MBA Sean, set the wps led using mstc_wps_util
	ps | pgrep mstc_wps_util | awk '{print "kill -9 " $0}' | sh
	
	mstc_wps_util -apcli&
	#MSTC MBA Sean, stop wps first
	ifconfig apcli0 up
	iwpriv apcli0 set ApCliEnable=0
	iwpriv apcli0 set WscConfMode=1 
	iwpriv apcli0 set WscMode=2
	iwpriv apcli0 set ApCliEnable=1
	iwpriv apcli0 set ApCliBssid=00:00:00:00:00:00
	iwpriv apcli0 set WscGetConf=1

else

	echo "2.4g disabled!"

fi

if [ "$if_5g_disable" != "1" ]; then

	#MSTC MBA Sean, execute only if 2.4g not execute it
	if [ "$wps_2g_wps_enable" != "7" -o "$if_2g_disable" = "1" ]; then
		ps | pgrep mstc_wps_util | awk '{print "kill -9 " $0}' | sh
			mstc_wps_util -apcli&
	fi
	
	#MSTC MBA Sean, stop wps first
	ifconfig apclii0 up
	iwpriv apclii0 set ApCliEnable=0
	iwpriv apclii0 set WscConfMode=1 
	iwpriv apclii0 set WscMode=2
	iwpriv apclii0 set ApCliEnable=1
	iwpriv apclii0 set ApCliBssid=00:00:00:00:00:00
	iwpriv apclii0 set WscGetConf=1

else

	echo "5g disabled!"

fi






