
include $(TOPDIR)/rules.mk

PKG_NAME:=cgi
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/cgi
	SECTION:=utils
	CATEGORY:=CGI
	TITLE:=CGI for GUI
	MAINTAINER:=IO-DATA
	DEPENDS:=+zlib libucix
endef

define Package/cgi/description
  CGI for GUI
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default

endef

define Package/cgi/install
	$(INSTALL_DIR) $(1)/www/cgi-bin/sec/
	$(CP) -af $(PKG_BUILD_DIR)/htmlparts/ $(1)/www/cgi-bin/sec/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/easysetup.cgi $(1)/www/cgi-bin/sec/
	$(INSTALL_DIR) $(1)/www/cgi-bin/htmlparts/
	$(CP) -af $(PKG_BUILD_DIR)/htmlparts/htmleasysetupredirect* $(1)/www/cgi-bin/htmlparts/
	$(CP) -af $(PKG_BUILD_DIR)/htmlparts/htmltop $(1)/www/cgi-bin/htmlparts/
	$(INSTALL_DIR) $(1)/www/
	$(CP) -af $(PKG_BUILD_DIR)/htdocs/ezinet.htm $(1)/www/
	$(CP) -af $(PKG_BUILD_DIR)/htdocs/ezinet_pre.htm $(1)/www/
	$(CP) -af $(PKG_BUILD_DIR)/htdocs/ioswinf.htm $(1)/www/
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/http_access_config.sh $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,cgi))

