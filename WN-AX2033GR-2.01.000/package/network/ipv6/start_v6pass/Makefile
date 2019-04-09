include $(TOPDIR)/rules.mk

PKG_NAME:=start_v6pass
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/start_v6pass
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=start_v6pass
  DEFAULT:=y
endef

define Package/start_v6pass/description
	start_v6pass
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
#Build/Compile = $(Build/Compile/Default)

define Package/start_v6pass/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/start_v6pass $(1)/usr/sbin/start_v6pass
#	$(INSTALL_BIN) ./src/start_v6pass $(1)/usr/sbin/start_v6pass
endef

$(eval $(call BuildPackage,start_v6pass))

