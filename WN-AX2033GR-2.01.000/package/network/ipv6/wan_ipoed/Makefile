include $(TOPDIR)/rules.mk

PKG_NAME:=wan_ipoed
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wan_ipoed
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=wan_ipoed
  DEFAULT:=y
endef

define Package/wan_ipoed/description
	wan_ipoed
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/wan_ipoed/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wan_ipoed $(1)/usr/sbin/wan_ipoed
endef

$(eval $(call BuildPackage,wan_ipoed))
