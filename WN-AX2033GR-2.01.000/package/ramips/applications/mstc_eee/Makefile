#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mstc_eee
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk


ifeq ($(CONFIG_TARGET_ramips_mt7620),y)
	TARGET_CFLAGS += -DCONFIG_RALINK_MT7620=y
	MAKE_FLAGS += CONFIG_RALINK_MT7620=y
endif

ifeq ($(CONFIG_TARGET_ramips_mt7621),y)
	TARGET_CFLAGS += -DCONFIG_RALINK_MT7621=y
	MAKE_FLAGS += CONFIG_RALINK_MT7621=y
endif

ifeq ($(CONFIG_TARGET_ramips_mt7628),y)
	TARGET_CFLAGS += -DCONFIG_RALINK_MT7628=y
	MAKE_FLAGS += CONFIG_RALINK_MT7628=y
endif

ifeq ($(CONFIG_TARGET_mediatek_mt7623_emmc),y)
	TARGET_CFLAGS += -DCONFIG_ARCH_MT7623=y
	MAKE_FLAGS += CONFIG_ARCH_MT7623=y
endif

ifeq ($(CONFIG_TARGET_mediatek_mt7623_mtd),y)
	TARGET_CFLAGS += -DCONFIG_ARCH_MT7623=y
	MAKE_FLAGS += CONFIG_ARCH_MT7623=y
endif

define Package/mstc_eee
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=Command to config switch 802.3az EEE function
  SUBMENU:=Applications
endef

define Package/mstc_eee/description
  An program to config switch 802.3az EEE function
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef
define Build/Configure
endef

define Package/mstc_eee/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/etc/init.d
ifeq ($(CONFIG_TARGET_ramips_mt7621),y)
	$(INSTALL_BIN) ./files/smart_speed $(1)/usr/sbin/smart_speed
	$(INSTALL_BIN) ./files/switch-7621-eee.sh $(1)/usr/sbin/switch-eee.sh
endif
endef

$(eval $(call BuildPackage,mstc_eee))
