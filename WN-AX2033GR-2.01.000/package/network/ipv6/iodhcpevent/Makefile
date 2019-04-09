include $(TOPDIR)/rules.mk

PKG_NAME:=iodhcpevent
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/iodhcpevent
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=iodhcpevent
  DEFAULT:=y
endef

define Package/iodhcpevent/description
	iodhcpevent
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/iodhcpevent/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iodhcpevent $(1)/usr/sbin/iodhcpevent
endef

$(eval $(call BuildPackage,iodhcpevent))
