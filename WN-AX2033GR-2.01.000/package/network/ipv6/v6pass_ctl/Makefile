include $(TOPDIR)/rules.mk
#include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=v6pass_ctl
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/v6pass_ctl
  SECTION:=utils
  CATEGORY:=Private/others
  SUBMENU:=iodata
  TITLE:=v6pass_ctl
  DEFAULT:=y
endef

define Package/v6pass_ctl/description
	v6pass_ctl
endef

V6PASS_CTL_FILE="./files/v6pass_ctl"

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(V6PASS_CTL_FILE) $(PKG_BUILD_DIR)/v6pass_ctl
endef

define Build/Compile/Default

endef

define Package/v6pass_ctl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/v6pass_ctl $(1)/usr/sbin/v6pass_ctl
endef

$(eval $(call BuildPackage,v6pass_ctl))
