#!/bin/sh
echo "Factory Reset Button Pressed!"

rm -rf /tmp/.uci >/dev/null
/usr/sbin/sys romreset 0 >/dev/null
/usr/bin/mstc_cfg_chksum chksum 1 | xargs /sbin/mstc_persist write cfg1Chksum >/dev/null
/usr/bin/mstc_cfg_chksum size 1 | xargs /sbin/mstc_persist write cfg1Size >/dev/null
/sbin/mstc_persist write cfgapply 1 >/dev/null
sync
sync
sleep 1
reboot


