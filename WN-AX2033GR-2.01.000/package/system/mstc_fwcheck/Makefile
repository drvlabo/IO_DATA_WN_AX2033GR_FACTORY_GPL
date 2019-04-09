#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mstc_fwcheck
PKG_RELEASE:=1

PKG_BUILD_DIR := $(KERNEL_BUILD_DIR)/$(PKG_NAME)
#STAMP_PREPARED := $(STAMP_PREPARED)_$(call confvar,CONFIG_MTD_REDBOOT_PARTS)

PKG_LICENSE:=GPLv2 GPLv2+
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/mstc_fwcheck
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=
  TITLE:=Utility for verify FW integrity
endef

define Package/mstc_fwcheck/description
 This package contains an utility to verify FW integrity
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mstc_fwcheck $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default
endef

define Package/mstc_fwcheck/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mstc_fwcheck $(1)/sbin/
endef

$(eval $(call BuildPackage,mstc_fwcheck))

