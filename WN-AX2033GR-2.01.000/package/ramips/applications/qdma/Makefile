#MSTC MBA SW Sean, 2015
#

include $(TOPDIR)/rules.mk


PKG_NAME:=qdma
PKG_RELEASE:=4200

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628 HNAT_V2
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/qdma
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Quick Direct Memory Access
  SUBMENU:=Applications
endef

define Package/qdma/description
  An program to query MTK hwqos feature
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/qdma $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/qdma/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qdma $(1)/usr/bin
endef


$(eval $(call BuildPackage,qdma))
