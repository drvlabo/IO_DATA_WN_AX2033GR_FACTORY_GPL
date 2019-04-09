include $(TOPDIR)/rules.mk

PKG_NAME:=APFind_V120
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/APFind_V120
	SECTION:=base
	CATEGORY:=Private/others
	SUBMENU:=mstc
	TITLE:=APFind_V120 
	MAINTAINER:=IO-DATA
	DEPENDS:=+zlib libucix
endef

define Package/APFind_V120/description
	APFind_V120
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/APFind_V120/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFind $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFind.conf $(1)/etc/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/apfcfg $(1)/etc/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFind.sh $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFNetCfg $(1)/usr/sbin/
	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFPasswd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFPass_Gen.sh $(1)/usr/sbin/
	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFTimeCfg $(1)/usr/sbin/
	
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/APFVerCfg $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,APFind_V120))

