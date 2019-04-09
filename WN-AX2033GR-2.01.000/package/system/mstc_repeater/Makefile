#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mstc_repeater
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/mstc_repeater
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=MSTC Repeater utility
  MENU:=1
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/repeater_radio_ctrl $(PKG_BUILD_DIR)/
	$(CP) ./files/repeater_status $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/mstc_repeater/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/repeater_search_bssid.lua $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/repeater_autoreconnect.lua $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/repeater_radio_onoff.lua $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/apcli_autoreconnect.lua $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/repeater_radio_ctrl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/repeater_status $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,mstc_repeater))
