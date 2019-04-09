include $(TOPDIR)/rules.mk

PKG_NAME:=rule_downloader
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/rule_downloader
  #SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  DEPENDS:=+libopenssl
  TITLE:=rule_downloader
  DEFAULT:=y
endef

define Package/rule_downloader/description
	rule_downloader
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/rule_downloader/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rule_downloader $(1)/usr/sbin/rule_downloader
endef

#$(eval $(call BuildPackage,rule_downloader,+libopenssl))
$(eval $(call BuildPackage,rule_downloader))
