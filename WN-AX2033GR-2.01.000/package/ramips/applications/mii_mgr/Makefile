#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mii_mgr
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=TARGET_ramips_mt7620 TARGET_ramips_mt7621 TARGET_ramips_mt7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/mii_mgr
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=mii_mgr
  SUBMENU:=Applications
endef

define Package/mii_mgr/description
  An program.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mii_mgr $(PKG_BUILD_DIR)/
	$(CP) ./files/mii_mgr_cl45 $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/mii_mgr/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mii_mgr $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mii_mgr_cl45 $(1)/usr/bin
endef


$(eval $(call BuildPackage,mii_mgr))

