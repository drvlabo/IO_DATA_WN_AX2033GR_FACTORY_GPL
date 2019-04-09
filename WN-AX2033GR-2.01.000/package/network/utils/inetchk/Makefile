# For OpenWRT compile
include $(TOPDIR)/rules.mk

PKG_NAME:=inetchk
PKG_VERSION:=1.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/inetchk/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+zlib
  TITLE:=Internet Connection Checking Program
endef

define Package/inetchk/Default/description
	This program use to check the Network Interface Status and Internet connection status.
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/inetchk $(PKG_BUILD_DIR)/
endef

define Package/inetchk
$(call Package/inetchk/Default)
endef

define Package/inetchk/description
$(call Package/inetchk/Default/description)
endef

define Build/Compile/Default

endef

define Package/inetchk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/inetchk $(1)/usr/bin/inetchk
endef


$(eval $(call BuildPackage,inetchk))
