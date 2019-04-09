# For OpenWRT compile
include $(TOPDIR)/rules.mk

PKG_NAME:=ddns
PKG_VERSION:=1.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/ddns/Default
	SECTION:=net
	CATEGORY:=Network
		SUBMENU:=IP Addresses and Names
	DEPENDS:=+libucix +miniupnpc
	TITLE:=Dynamic DNS Service Program
endef

define Package/ddns/Default/description
	This program use to turn on and handle the dynamic dns service.
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/ddns $(PKG_BUILD_DIR)/
endef

define Package/ddns
$(call Package/ddns/Default)
endef

define Package/ddns/description
$(call Package/ddns/Default/description)
endef

define Build/Compile/Default
endef

define Package/ddns/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ddns $(1)/usr/sbin/ddns
	
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_BIN) ./files/etc/init.d/ddns $(1)/etc/init.d/
endef


$(eval $(call BuildPackage,ddns))
