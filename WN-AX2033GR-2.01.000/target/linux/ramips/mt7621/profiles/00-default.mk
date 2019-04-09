#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/MT7621
	NAME:=Default Profile
	PACKAGES:=\
		-swconfig -rt2x00 \
		ated hwnat reg gpio btnd switch ethstt uci2dat mii_mgr watchdog 8021xd eth_mac\
		wireless-tools uboot-envtools \
		kmod-hw_nat kmod-mt7603e kmod-mt7615e \
		luci iptables libopenssl pptpd ppp kmod-mppe miniupnpd luci-app-upnp \
		syscmd-r1
endef

define Profile/MT7621/Description
	Default package set compatible with most boards.
endef
$(eval $(call Profile,MT7621))
