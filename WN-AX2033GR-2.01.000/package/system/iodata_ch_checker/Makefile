#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iodata_ch_checker
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/iodata_ch_checker
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IO-DATA Channel checker mechanism
  DEPENDS:=  
endef

define Package/iodata_ch_checker/description
 This package contains an utility to which provide by IODATA to check channel on W56
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/IO5GCCRP $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default
endef

define Package/iodata_ch_checker/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/IO5GCCRP $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	cp ./files/iodata_dfs_channel_reset $(1)/etc/init.d
endef

$(eval $(call BuildPackage,iodata_ch_checker))
