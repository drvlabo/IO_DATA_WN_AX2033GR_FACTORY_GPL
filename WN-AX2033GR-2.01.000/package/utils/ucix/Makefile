#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

#UCI_VERSION=2011-11-14
#UCI_RELEASE=1

PKG_NAME:=ucix
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk


# set to 1 to enable debugging
#DEBUG=

define Package/libucix
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libuci
  TITLE:=Unified Configuration Interface (UCI) API library
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

#define Package/uci
#  SECTION:=base
#  CATEGORY:=Base system
#  DEPENDS:=+libuci
#  TITLE:=Utility for the Unified Configuration Interface (UCI)
#endef

#define Package/libuci-lua
#  SECTION=libs
#  CATEGORY=Libraries
#  DEPENDS:=+libuci +liblua
#  TITLE:=Lua plugin for UCI
#endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib

#CMAKE_OPTIONS = \
#	-DLUAPATH=/usr/lib/lua \
#	$(if $(DEBUG),-DUCI_DEBUG=ON)

define Package/libucix/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_BUILD_DIR)/libucix.so $(1)/lib/
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/ucix.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/list.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libucix.so $(1)/usr/lib
#	$(CP) $(PKG_BUILD_DIR)/libucix.a $(1)/usr/lib
endef

$(eval $(call BuildPackage,libucix))

