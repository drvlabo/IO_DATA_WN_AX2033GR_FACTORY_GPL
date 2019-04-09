#
# MSTC Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=btnCallback
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/btnCallback
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=MSTC Daemon for button callback function
  SUBMENU:=Applications
endef

define Package/btnCallback/description
  MSTC Daemon for button callback function
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/btnCbkd $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default
endef

define Package/btnCallback/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/btnCbkd $(1)/usr/bin
endef


$(eval $(call BuildPackage,btnCallback))

