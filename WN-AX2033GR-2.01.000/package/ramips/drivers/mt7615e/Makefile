# All rights reserved.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mt7615e
P4REV:=
PKG_VERSION:=4.4.1.0
PKG_SOURCE:=
PKG_SOURCE_URL:=
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_KCONFIG:= 

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mt7615e
  CATEGORY:=MTK Properties
  TITLE:=MTK MT7615e wifi AP driver
  FILES:=$(PKG_BUILD_DIR)/mt_wifi_ap/mt7615e.ko
  SUBMENU:=Drivers
  MENU:=1
endef

define KernelPackage/mt7615e/config
	source "$(SOURCE)/config.in"
endef

define Build/Prepare
	mkdir $(PKG_BUILD_DIR)/mt_wifi_ap/
	cp ./files/mt7615e.ko $(PKG_BUILD_DIR)/mt_wifi_ap/
endef

define Build/Compile

endef

define KernelPackage/mt7615e/install
	$(INSTALL_DIR) $(1)/lib/wifi/

	$(INSTALL_DIR) $(1)/etc/wireless/mt7615e5/ ; \
	$(INSTALL_BIN) ./files/mt7615e5.sh $(1)/lib/wifi/ ; \
	$(INSTALL_BIN) ./files/mt7615e5.dat $(1)/etc/wireless/mt7615e5/ ; \
	$(INSTALL_BIN) ./files/mt7615e*.bin $(1)/etc/wireless/mt7615e5/ ; \
	echo $(PKG_VERSION) > $(1)/etc/wireless/mt7615e5/version; \
	$(INSTALL_DIR) $(1)/etc/wireless/mt7615e/ ; \
	$(INSTALL_BIN) ./files/7615*.dat $(1)/etc/wireless/mt7615e/ ;
endef

$(eval $(call KernelPackage,mt7615e))
