# All rights reserved.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mt7603e
P4REV:=
PKG_VERSION:=4.0.1.0
PKG_SOURCE:=
PKG_SOURCE_URL:=
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_KCONFIG:=

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mt7603e
  CATEGORY:=MTK Properties
  TITLE:=MTK MT7603e wifi AP driver
  FILES:=$(PKG_BUILD_DIR)/rlt_wifi_ap/mt7603e.ko
  SUBMENU:=Drivers
  MENU:=1
endef

define KernelPackage/mt7603e/config
	source "$(SOURCE)/config.in"
endef

define Build/Prepare
	mkdir $(PKG_BUILD_DIR)/rlt_wifi_ap/
	cp ./files/mt7603e.ko $(PKG_BUILD_DIR)/rlt_wifi_ap/
endef

define Build/Compile

endef

define KernelPackage/mt7603e/install
	$(INSTALL_DIR) $(1)/lib/wifi/
	$(INSTALL_BIN) ./files/mt7603e.sh $(1)/lib/wifi/
	$(INSTALL_DIR) $(1)/etc/wireless/mt7603e/
	$(INSTALL_BIN) ./files/mt7603e.dat $(1)/etc/wireless/mt7603e/
	$(INSTALL_BIN) ./files/mt7603e.eeprom.bin $(1)/etc/wireless/mt7603e/
	echo $(PKG_VERSION) > $(1)/etc/wireless/mt7603e/version
endef

$(eval $(call KernelPackage,mt7603e))
