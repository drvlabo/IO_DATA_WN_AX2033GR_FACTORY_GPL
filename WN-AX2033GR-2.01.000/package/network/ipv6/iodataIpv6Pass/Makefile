#
# __MSTC__, Smith, ipv6 passthrough
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iodataIpv6Pass
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

ifeq ($(DUMP)$(PKG_VERSION),)
  PKG_VERSION:=0.0.0.1
endif

include $(INCLUDE_DIR)/package.mk

define Package/iodataIpv6Pass
  SECTION:=base
  CATEGORY:=Private/others
  SUBMENU:=iodata
  DEPENDS:=+kmod-v6pass +kmod-v6passCompat
  TITLE:=iodata ipv6 passthrough
#  AUTOLOAD:=$(call AutoLoad,99,mtd_locked)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/iodataIpv6Pass/Description
This package is iodata module for ipv6 passthrough
endef

define Package/iodataIpv6Pass/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/iodataIpv6Pass.init $(1)/etc/init.d/iodataIpv6Pass
endef

$(eval $(call BuildPackage,iodataIpv6Pass))


