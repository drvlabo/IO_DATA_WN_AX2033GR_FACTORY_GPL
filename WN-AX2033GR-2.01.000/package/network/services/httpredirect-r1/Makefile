# For OpenWRT compile
include $(TOPDIR)/rules.mk

PKG_NAME:=httpredirect
PKG_VERSION:=r1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/httpredirect/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=
  TITLE:=HTTP redirect function
endef

define Package/httpredirect/Default/description
	HTTP redirect checking function
endef

define Package/httpredirect
	$(call Package/httpredirect/Default)
endef

define Package/httpredirect/description
	$(call Package/httpredirect/Default/description)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/httpredirect/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,httpredirect))
