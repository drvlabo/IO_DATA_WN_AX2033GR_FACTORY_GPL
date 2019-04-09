include $(TOPDIR)/rules.mk

PKG_NAME:=ioilas
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ioilas
#  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  DEPENDS:=+libopenssl
  TITLE:=ioilas
  DEFAULT:=y
endef

define Package/ioilas/description
	ioilas
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Build/Compile/Default

endef

define Package/ioilas/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ioilas $(1)/usr/sbin/ioilas
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ioudhcpc.sh $(1)/etc/ioudhcpc.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6c.conf $(1)/etc/dhcp6c.conf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6c-pd.conf $(1)/etc/dhcp6c-pd.conf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcp6c-script $(1)/etc/dhcp6c-script
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipv6pdb.bin $(1)/etc/ipv6pdb.bin
endef

$(eval $(call BuildPackage,ioilas))
