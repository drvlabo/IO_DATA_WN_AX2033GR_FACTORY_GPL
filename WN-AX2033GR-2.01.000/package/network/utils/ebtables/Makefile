#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ebtables
PKG_VERSION:=2.0.10-4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/ebtables
PKG_MD5SUM:=506742a3d44b9925955425a659c1a8d0

PKG_BUILD_DIR:=$(BUILD_DIR)/ebtables-v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/ebtables
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  DEPENDS:=+kmod-ebtables
  TITLE:=Ethernet bridge firewall administration utility
  URL:=http://ebtables.sourceforge.net/
endef

define Package/ebtables-utils
  $(call Package/ebtables)
  DEPENDS += ebtables
  TITLE:=ebtables save/restore utilities
endef

define Package/ebtables/description
	The ebtables program is a filtering tool for a bridging firewall. The
	filtering is focussed on the Link Layer Ethernet frame fields. Apart
	from filtering, it also gives the ability to alter the Ethernet MAC
	addresses and implement a brouter.
endef

define Package/ebtables-utils/description
	$(call Package/ebtables/description)
endef

define Package/ebtables-siteblock
  $(call Package/ebtables)
  DEPENDS += ebtables +kmod-ebtables-siteblock
  TITLE:=ebtables siteblock support
endef

define Package/ebtables-siteblock/description
	Support target siteblock
endef

define Package/ebtables-time-match
  $(call Package/ebtables)
  DEPENDS += ebtables +kmod-ebtables-time
  TITLE:=ebtables time match support
endef

define Package/ebtables-time-match/description
	Support match module time
endef

TARGET_CFLAGS += \
	-I$(LINUX_DIR)/include/linux/netfilter_bridge

MAKE_VARS += EXT_LIBSI="$(LIBGCC_S)"

ifeq ($(CONFIG_PACKAGE_ebtables-siteblock),y)
MAKE_VARS += CONFIG_EBT_TARGET_SITEBLOCK="$(CONFIG_PACKAGE_ebtables-siteblock)"
endif

ifeq ($(CONFIG_PACKAGE_ebtables-time-match),y)
MAKE_VARS += CONFIG_EBT_MATCH_TIME="$(CONFIG_PACKAGE_ebtables-time-match)"
endif

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LIBDIR="/usr/lib/ebtables"

define Package/ebtables/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ethertypes $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/lib/ebtables
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lib*.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/extensions/*.so $(1)/usr/lib/ebtables/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ebtables $(1)/usr/sbin/
endef

define Package/ebtables-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ebtables-save $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ebtables-restore $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ebtables))
$(eval $(call BuildPackage,ebtables-utils))
$(eval $(call BuildPackage,ebtables-siteblock))
$(eval $(call BuildPackage,ebtables-time-match))
