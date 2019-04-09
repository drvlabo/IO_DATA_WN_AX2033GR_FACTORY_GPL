#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eth_mac
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/eth_mac
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Command to config eth mac
  SUBMENU:=Applications
endef

define Package/eth_mac/description
  An program to config eth mac.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/eth_mac $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/eth_mac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eth_mac $(1)/usr/bin
endef


$(eval $(call BuildPackage,eth_mac))

