include $(TOPDIR)/rules.mk
PKG_NAME:=mstc_dual_config
PKG_VERSION:=r1

include $(INCLUDE_DIR)/package.mk

MAKE_ARGS:= \
	CC="$(TARGET_CROSS)gcc"
	
define Package/mstc_dual_config
  SECTION:=base
  CATEGORY:=Private/others
  SUBMENU:=mstc
  TITLE:=mstc dual config
  DEPENDS:=+uci_MSTC_DUAL_CONFIG_UCI_COMMIT
endef

define Build/Prepare

endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/mstc_dual_config/compile
	
endef

define Package/mstc_dual_config/install

endef

$(eval $(call BuildPackage,mstc_dual_config))

