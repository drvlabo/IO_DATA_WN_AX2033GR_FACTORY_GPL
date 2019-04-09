include $(TOPDIR)/rules.mk

PKG_NAME:=ip4ov6jp_start
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ip4ov6jp_start
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=ip4ov6jp_start
  DEFAULT:=y
endef

define Package/ip4ov6jp_start/description
	ip4ov6jp_start
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ip4ov6jp_start/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip4ov6jp_start $(1)/usr/sbin/ip4ov6jp_start
endef

$(eval $(call BuildPackage,ip4ov6jp_start))
