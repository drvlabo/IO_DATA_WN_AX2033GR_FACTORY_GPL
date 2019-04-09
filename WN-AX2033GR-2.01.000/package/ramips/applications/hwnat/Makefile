#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hwnat
PKG_RELEASE:=4200

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628 RALINK_MT7623 HNAT_V2
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/hwnat
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Hardware NAT command
  DEPENDS:=@PACKAGE_kmod-hw_nat
  SUBMENU:=Applications
endef

define Package/hwnat/description
  An program to query info from hwnat driver
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/ac $(PKG_BUILD_DIR)/
	$(CP) ./files/acl $(PKG_BUILD_DIR)/
	$(CP) ./files/hwnat $(PKG_BUILD_DIR)/
	$(CP) ./files/mtr $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/hwnat/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/acl $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hwnat $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mtr $(1)/bin
	# Terence, MSTC, 20160502 Add hwnat enable/disable script
	$(INSTALL_BIN) ./files/hwnat.init $(1)/etc/init.d/hwnat
	$(INSTALL_BIN) ./files/hwnat-enable.sh $(1)/usr/sbin
	$(INSTALL_BIN) ./files/hwnat-disable.sh $(1)/usr/sbin
endef


$(eval $(call BuildPackage,hwnat))

