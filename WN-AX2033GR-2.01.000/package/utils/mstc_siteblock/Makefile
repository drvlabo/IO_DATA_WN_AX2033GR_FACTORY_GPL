#MSTC MBA SW Terence, 2016
#

include $(TOPDIR)/rules.mk


PKG_NAME:=mstc_siteblock
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/mstc_siteblock
  SECTION:=base
  CATEGORY:=Private/others
  SUBMENU:=mstc
  TITLE:=MSTC Site Block utility
  DEPENDS:=+libpthread +libuci
endef

define Package/mstc_siteblock/description
  An program to control bad site access.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mstc_sbd $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/mstc_siteblock/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/siteblock $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mstc_sbd $(1)/usr/bin
	$(INSTALL_BIN) ./files/mstc_sbd.init $(1)/etc/init.d/mstc_sbd
	$(INSTALL_BIN) ./files/mstc_sbd.firewall $(1)/etc/siteblock/firewall.include
	$(INSTALL_BIN) ./files/mstc_sbd.conf $(1)/etc/siteblock/config
endef


$(eval $(call BuildPackage,mstc_siteblock))
