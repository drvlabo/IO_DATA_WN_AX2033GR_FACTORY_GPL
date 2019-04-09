# For OpenWRT compile
include $(TOPDIR)/rules.mk

PKG_NAME:=autobridge
PKG_VERSION:=r1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/autobridge/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=
  TITLE:=Auto bridge function
endef

define Package/autobridge/Default/description
	This program will determine if it is necessary to change the mode from router to AP(bridge) automatically.
endef

define Package/autobridge
	$(call Package/autobridge/Default)
endef

define Package/autobridge/description
	$(call Package/autobridge/Default/description)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/autobridge/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,autobridge))
