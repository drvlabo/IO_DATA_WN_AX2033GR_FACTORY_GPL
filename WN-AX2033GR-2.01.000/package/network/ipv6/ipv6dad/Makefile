include $(TOPDIR)/rules.mk

PKG_NAME:=ioipv6dad
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ioipv6dad
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=ioipv6dad
  DEFAULT:=y
endef

define Package/ioipv6dad/description
	ioipv6dad
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ioipv6dad/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ioipv6dad $(1)/usr/sbin/ioipv6dad
endef

$(eval $(call BuildPackage,ioipv6dad))
