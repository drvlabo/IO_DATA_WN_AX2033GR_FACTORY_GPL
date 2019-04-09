#MSTC MBA SW Sean, 2015
#

include $(TOPDIR)/rules.mk


PKG_NAME:=mstc_wps_util
PKG_RELEASE:=4200

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))

include $(INCLUDE_DIR)/package.mk
#include $(INCLUDE_DIR)/kernel.mk

define Package/mstc_wps_util
  SECTION:=base
  CATEGORY:=Private/others
  SUBMENU:=mstc
  TITLE:=MSTC WPS utility
  DEPENDS:=+libpthread
endef

define Package/mstc_wps_util/description
  An program to query WPS status
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mstc_wps_util $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/mstc_wps_util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mstc_wps_util $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/wireless
	$(CP) ./files/*.lua  $(1)/etc/wireless
endef


$(eval $(call BuildPackage,mstc_wps_util))
