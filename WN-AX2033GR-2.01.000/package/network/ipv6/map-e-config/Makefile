include $(TOPDIR)/rules.mk

PKG_NAME:=map-e-config
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/map-e-config
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  DEPENDS:=+libopenssl
  TITLE:=map-e-config
  DEFAULT:=y
endef

define Package/map-e-config/description
	map-e-config
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/map-e-config/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/map-e-config $(1)/usr/sbin/map-e-config
endef

#$(eval $(call BuildPackage,map-e-config,+libopenssl))
$(eval $(call BuildPackage,map-e-config))
