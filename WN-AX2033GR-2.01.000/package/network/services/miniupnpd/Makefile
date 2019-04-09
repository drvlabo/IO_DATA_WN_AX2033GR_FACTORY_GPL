#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=miniupnpd
PKG_VERSION:=2.0.20161216
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://miniupnp.free.fr/files
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=6f182faa5835b573168ceb0258d7bd77

PKG_MAINTAINER:=Markus Stenberg <fingon@iki.fi>
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk

define Package/miniupnpd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iptables +libip4tc +IPV6:libip6tc +IPV6:ip6tables +libuuid
  TITLE:=Lightweight UPnP IGD, NAT-PMP & PCP daemon
  SUBMENU:=Firewall
  URL:=http://miniupnp.free.fr/
endef

define Package/miniupnpd/config
	menu "Configuration"
		depends on PACKAGE_miniupnpd
		source "$(SOURCE)/Config.in"
	endmenu
endef

define Package/miniupnpd/conffiles
/etc/config/upnpd
endef

define Package/miniupnpd/postinst
#!/bin/sh

if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/99-miniupnpd )
  rm -f /etc/uci-defaults/99-miniupnpd
fi

exit 0
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	echo "OpenWrt" | tr \(\)\  _ >$(PKG_BUILD_DIR)/os.openwrt
endef

MAKE_FLAGS += \
	TARGET_OPENWRT=1 TEST=0 \
	LIBS="" \
	CC="$(TARGET_CC) -DIPTABLES_143 \
		-lip4tc -luuid -lip4tc $(if $(CONFIG_MINIUPNPD_IPV6),-lip6tc) $(if $(CONFIG_PACKAGE_switch_WLLLL),-DCONFIG_PACKAGE_switch_WLLLL) $(if $(CONFIG_PACKAGE_switch_LLLLW),-DCONFIG_PACKAGE_switch_LLLLW) $(if $(CONFIG_TARGET_ramips_mt7621),-DCONFIG_TARGET_ramips_mt7621) $(if $(CONFIG_PACKAGE_mstc_simple_log),-DHAVE_SIMPLE_LOG)" \
	CONFIG_OPTIONS="$(if $(CONFIG_MINIUPNPD_IPV6),--ipv6) --leasefile $(if $(CONFIG_MINIUPNPD_VENDORCFG),--vendorcfg) $(if $(CONFIG_MINIUPNPD_PCP_PEER),--pcp-peer) $(if $(CONFIG_MINIUPNPD_PORTINUSE),--portinuse) $(if $(CONFIG_MINIUPNPD_STRICT),--strict)" \
	-f Makefile.linux \
	miniupnpd

define Package/miniupnpd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults $(1)/etc/hotplug.d/iface $(1)/usr/share/miniupnpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/miniupnpd $(1)/usr/sbin/miniupnpd
	$(INSTALL_BIN) ./files/miniupnpd.init $(1)/etc/init.d/miniupnpd
	$(INSTALL_CONF) ./files/upnpd.config $(1)/etc/config/upnpd
	$(INSTALL_DATA) ./files/miniupnpd.hotplug $(1)/etc/hotplug.d/iface/50-miniupnpd
	$(INSTALL_DATA) ./files/miniupnpd.defaults $(1)/etc/uci-defaults/99-miniupnpd
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/miniupnpd/firewall.include
endef

$(eval $(call BuildPackage,miniupnpd))
