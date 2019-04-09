include $(TOPDIR)/rules.mk

PKG_NAME:=ioragwset
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ioragwset
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=ioragwset
  DEFAULT:=y
endef

define Package/ioragwset/description
	ioragwset
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ioragwset/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ioragwset $(1)/usr/sbin/ioragwset
endef

$(eval $(call BuildPackage,ioragwset))
