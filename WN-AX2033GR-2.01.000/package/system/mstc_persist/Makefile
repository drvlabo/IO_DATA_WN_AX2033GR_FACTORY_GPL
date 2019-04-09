#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mstc_persist
PKG_RELEASE:=1

PKG_BUILD_DIR := $(KERNEL_BUILD_DIR)/$(PKG_NAME)
#STAMP_PREPARED := $(STAMP_PREPARED)_$(call confvar,CONFIG_MTD_REDBOOT_PARTS)

PKG_LICENSE:=GPLv2 GPLv2+
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/mstc_persist
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=+libpthread
  TITLE:=Utility for read/write parameters in persist partition.
endef

define Package/mstc_persist/description
 This package contains an utility to read/write parameters in persist partition.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mstc_persist $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default
endef

define Package/mstc_persist/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mstc_persist $(1)/sbin/
endef

$(eval $(call BuildPackage,mstc_persist))

