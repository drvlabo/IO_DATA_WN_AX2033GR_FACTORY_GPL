# All rights reserved.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ip4ov6jp
P4REV:=
#PKG_VERSION:=2.0.0.0
PKG_SOURCE:=
PKG_SOURCE_URL:=
#PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_KCONFIG:= 
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/ip4ov6jp
  CATEGORY:=Other modules
  DEPENDS:= +kmod-iptunnel6
  TITLE:=ip4ov6jp
  FILES:=$(PKG_BUILD_DIR)/ip4ov6jp.ko
  KCONFIG:=
  SUBMENU:=Other modules
  DEFAULT:=y
#  MENU:=1
endef

define KernelPackage/ip4ov6jp/description

endef

EXTRA_KCONFIG:= \
	CONFIG_IPV6_IP4OV6JP_TUNNEL=m

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	$(EXTRA_KCONFIG)

#define KernelPackage/ip4ov6jp/config
#	source "$(SOURCE)/config.in"
#endef

#MSTC MBA Sean COPY ip4ov6jp_ipsec.ko or ip4ov6jp.ko denepnds on whether we enable ipsec or not
ifneq ($(CONFIG_PACKAGE_kmod-ipsec),)
	IPVOV6JP_FILE="./files/ip4ov6jp_ipsec.ko"
else
	IPVOV6JP_FILE="./files/ip4ov6jp.ko"
endif
	
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(IPVOV6JP_FILE) $(PKG_BUILD_DIR)/ip4ov6jp.ko
endef

define Build/Compile
#	$(MAKE) -C "$(LINUX_DIR)" \
#		$(MAKE_OPTS) \
#		modules
endef

define KernelPackage/ip4ov6jp/install
#	$(INSTALL_DIR) $(1)/lib/modules/3.10.14
#	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip4ov6jp.ko $(1)/lib/modules/3.10.14/ip4ov6jp.ko
	$(INSTALL_DIR) $(1)/lib/netifd/proto/
	$(INSTALL_DIR) $(1)/etc/v6jp/
	$(CP) ./files/lib/netifd/proto/* $(1)/lib/netifd/proto/
	$(CP) ./files/etc/v6jp/* $(1)/etc/v6jp/
endef

$(eval $(call KernelPackage,ip4ov6jp))
