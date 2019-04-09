echo "gpio btn wps!"

vifs=`uci show wireless | grep "=wifi-iface" | sed -n "s/=wifi-iface//gp"`

#MBA Sean, default is off
wps_2g_wps_enable="0"
wps_5g_wps_enable="0"

if_2g_disable="0"
if_5g_disable="0"

if_2g_apclienable="0"
if_5g_apclienable="0"

num_2g_vifs=0
num_5g_vifs=0

mode="ap"

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
				
				mode=`uci -q get ${vif}.mode`
				
				if [ "$mode" == "client" ]; then
					if_2g_apclienable=`uci -q get ${vif}.apcli_enable`
				fi
                ;;
            mt7610e | mt7612e | mt7615e5)
				wps_5g_wps_enable=`uci -q get wireless.${device}.wsc_confmode`
				#MSTC MBA Sean, only check first interface is disable or not 
				if [ $num_5g_vifs == 0 ]; then
					if_5g_disable=`uci -q get ${vif}.disabled`
					num_5g_vifs=`expr $num_5g_vifs + 1`
				fi
				
				mode=`uci -q get ${vif}.mode`
				
				if [ "$mode" == "client" ]; then
					if_5g_apclienable=`uci -q get ${vif}.apcli_enable`
				fi
                ;;
            * )
                echo "device $device not recognized!! " >>/tmp/wifi.log
                ;;
        esac            
		
done

REPEATER_MODE=`uci show network | grep network.wan.mode | sed -n "s/network.wan.mode=//gp"`
REPEATER_BAND=`uci show wireless | grep wireless.repeater.band | sed -n "s/wireless.repeater.band=//gp"`

#MSTC MBA Sean, add case for null value
if [ ! "$if_2g_apclienable" ]; then
	if_2g_apclienable="0"
fi

if [ ! "$if_5g_apclienable" ]; then
	if_5g_apclienable="0"
fi

if [ "$REPEATER_MODE" == "repeater" ]; then
	if [ "$REPEATER_BAND" != "" ]; then
		mstc_wps_util -apcli -repeater -repeater_band $REPEATER_BAND -en2gapcli $if_2g_apclienable -en5gapcli $if_5g_apclienable&
	else
		mstc_wps_util -apcli -repeater -en2gapcli $if_2g_apclienable -en5gapcli $if_5g_apclienable&
	fi

	#MSTC MBA Sean, kill repeater_radio_ctrl first
	killall repeater_radio_ctrl
	#MSTC MBA Sean, down the wifi interface, because Customer want AP down if apcli doesn't connect to root AP
	#the wifi ap interface will be called up by repeater's wifi link monitor daemon
	ifconfig ra0 down
	ifconfig rai0 down
	
	ifconfig apcli0 up
	iwpriv apcli0 set ApCliEnable=0
	iwpriv apcli0 set WscConfMode=1 
	iwpriv apcli0 set WscMode=2
	iwpriv apcli0 set ApCliEnable=1
	iwpriv apcli0 set ApCliBssid=00:00:00:00:00:00
	iwpriv apcli0 set WscGetConf=1
	
	ifconfig apclii0 up
	iwpriv apclii0 set ApCliEnable=0
	iwpriv apclii0 set WscConfMode=1 
	iwpriv apclii0 set WscMode=2
	iwpriv apclii0 set ApCliEnable=1
	iwpriv apclii0 set ApCliBssid=00:00:00:00:00:00
	iwpriv apclii0 set WscGetConf=1

else

	if [ "$wps_2g_wps_enable" = "7" -a "$if_2g_disable" != "1" ]; then
		#MSTC MBA Sean, set the wps led using mstc_wps_util
		ps | pgrep mstc_wps_util | awk '{print "kill -9 " $0}' | sh
	
		mstc_wps_util&
		#MSTC MBA Sean, stop wps first
		iwpriv ra0 set WscStop=1
		iwpriv ra0 set WscConfMode=7
		iwpriv ra0 set WscMode=2
		iwpriv ra0 set WscGetConf=1

	else

		echo "2.4g disabled or 2.4g wps disabled!"

	fi

	if [ "$wps_5g_wps_enable" = "7" -a "$if_5g_disable" != "1" ]; then

		#MSTC MBA Sean, execute only if 2.4g not execute it
		if [ "$wps_2g_wps_enable" != "7" -o "$if_2g_disable" = "1" ]; then
			ps | pgrep mstc_wps_util | awk '{print "kill -9 " $0}' | sh
				mstc_wps_util& 
		fi
	
		#MSTC MBA Sean, stop wps first
		iwpriv rai0 set WscStop=1
		iwpriv rai0 set WscConfMode=7
		iwpriv rai0 set WscMode=2
		iwpriv rai0 set WscGetConf=1

	else

		echo "5g disabled or 5g wps disabled!"

	fi
fi
