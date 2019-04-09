#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iodata_auto_fwupdate
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/iodata_auto_fwupdate
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IO-DATA Auto FW update mechanism
  DEPENDS:=+libmicroxml +libuci
  MENU:=1
endef

define Package/iodata_auto_fwupdate/config
  source "$(SOURCE)/Config.in"
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/auto_fwupdate $(PKG_BUILD_DIR)/
	$(CP) ./files/auto_fwupdate_scheduler $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/iodata_auto_fwupdate/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/auto_fwupdate $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/auto_fwupdate_scheduler $(1)/usr/sbin/
	cp -a ./files/* $(1)/
endef

$(eval $(call BuildPackage,iodata_auto_fwupdate))
