include $(TOPDIR)/rules.mk

PKG_NAME:=dhcpv6c
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/dhcpv6c
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=dhcpv6c
  DEFAULT:=y
endef

define Package/dhcpv6c/description
	dhcpv6c
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/dhcpv6c/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcpv6c $(1)/usr/sbin/dhcpv6c
endef

$(eval $(call BuildPackage,dhcpv6c))
