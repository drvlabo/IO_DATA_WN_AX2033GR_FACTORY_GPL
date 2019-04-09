# For OpenWRT compile
include $(TOPDIR)/rules.mk

PKG_NAME:=accel-pptp
PKG_VERSION:=1.3.3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

#include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/accel-pptp/Default
	SECTION:=net
	CATEGORY:=Network
		SUBMENU:=VPN
	DEPENDS:=
	TITLE:=Accel-PPTP
endef

define Package/accel-pptp/Default/description
	PPTP server
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/accel-pptp
$(call Package/accel-pptp/Default)
endef

define Package/accel-pptp/description
$(call Package/accel-pptp/Default/description)
endef


define Package/accel-pptp/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pptpctrl $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/etc/pptpd.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/pptpd.init $(1)/etc/init.d/pptpd
	$(INSTALL_DIR) $(1)/etc/ppp
	$(INSTALL_DATA) ./files/etc/ppp/options.pptpd $(1)/etc/ppp/
	#__MSTC__, Support PPTPD VPN ip changed
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/70-change-lanip $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/pptpd
	$(INSTALL_DATA) ./files/etc/pptpd/firewall.include $(1)/etc/pptpd/
	$(INSTALL_DIR) $(1)/etc/avahi/user-autoip-action
	$(INSTALL_BIN) ./files/etc/avahi/pptpd.action $(1)/etc/avahi/user-autoip-action/
endef


$(eval $(call BuildPackage,accel-pptp))
