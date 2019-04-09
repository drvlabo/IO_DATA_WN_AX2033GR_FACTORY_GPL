include $(TOPDIR)/rules.mk

PKG_NAME:=ioip6racfg
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ioip6racfg
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=ioip6racfg
  DEFAULT:=y
endef

define Package/ioip6racfg/description
	ioip6racfg
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ioip6racfg/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ioip6racfg $(1)/usr/sbin/ioip6racfg
endef

$(eval $(call BuildPackage,ioip6racfg))
