#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=reg
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_CONFIG_DEPENDS:=

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/reg
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Read/Write registers from user space
  SUBMENU:=Applications
  DEPENDS:=+kmod-rdm
endef

define Package/reg/description
  An program to read/write ralink register.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/reg $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile/Default
endef

define Package/reg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/reg $(1)/usr/bin
endef


$(eval $(call BuildPackage,reg))

