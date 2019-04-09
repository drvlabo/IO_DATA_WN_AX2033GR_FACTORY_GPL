#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mstc_simple_log
PKG_RELEASE:=1

PKG_BUILD_DIR := $(KERNEL_BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/mstc_simple_log
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=Utility for read/write simple log for LOG page.
  DEFAULT:=y
  DEPENDS:=
endef

define Package/mstc_simple_log/description
 This package contains an utility to read/write simple log for LOG page.
endef

define Build/Prepare

endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/mstc_dual_config/compile
	
endef

define Package/mstc_simple_log/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./src/simple_logrec.sh $(1)/sbin/
endef

$(eval $(call BuildPackage,mstc_simple_log))

