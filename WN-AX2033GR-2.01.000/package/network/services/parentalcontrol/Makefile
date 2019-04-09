#
# Copyright (C) 2006-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=parentalcontrol
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/parentalcontrol
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Parental Control for service access time limit
  DEFAULT:=y
endef

define Package/parentalcontrol/description
 This package contains an utility to implement parental control for service access time limit.
 It will generate iptables rule to time limit service access.
endef

define Build/Prepare

endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/parentalcontrol/compile

endef

define Package/parentalcontrol/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/parentalcontrol.init $(1)/etc/init.d/parentalcontrol
endef

$(eval $(call BuildPackage,parentalcontrol))
