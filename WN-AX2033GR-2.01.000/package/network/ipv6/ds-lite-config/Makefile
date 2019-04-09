include $(TOPDIR)/rules.mk

PKG_NAME:=ds-lite-config
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ds-lite-config
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=ds-lite-config
  DEFAULT:=y
endef

define Package/ds-lite-config/description
	ds-lite-config
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ds-lite-config/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ds-lite-config $(1)/usr/sbin/ds-lite-config
endef

$(eval $(call BuildPackage,ds-lite-config))
