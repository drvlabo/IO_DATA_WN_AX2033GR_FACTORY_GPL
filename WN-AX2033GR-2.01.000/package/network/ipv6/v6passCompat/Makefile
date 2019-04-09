# All rights reserved.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=v6passCompat
P4REV:=
#PKG_VERSION:=2.0.0.0
PKG_SOURCE:=
PKG_SOURCE_URL:=
#PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_KCONFIG:= 
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/v6passCompat
  CATEGORY:=Other modules
  DEPENDS:=kmod-ipt-conntrack
  TITLE:=v6passCompat
  FILES:=$(PKG_BUILD_DIR)/v6passCompat.ko
  KCONFIG:=
  SUBMENU:=Other modules
  DEFAULT:=y
#  MENU:=1
endef

define KernelPackage/v6passCompat/description

endef

EXTRA_KCONFIG:= \
	CONFIG_V6PASS_COMPAT=m

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	$(EXTRA_KCONFIG)

#define KernelPackage/v6passCompat/config
#	source "$(SOURCE)/config.in"
#endef

#MSTC MBA Sean COPY v6passCompat_ipsec.ko or v6passCompat.ko denepnds on whether we enable ipsec or not
ifneq ($(CONFIG_PACKAGE_kmod-ipsec),)
	V6PASSCOMPAT_FILE="./files/v6passCompat_ipsec.ko"
else
	V6PASSCOMPAT_FILE="./files/v6passCompat.ko"
endif

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(V6PASSCOMPAT_FILE) $(PKG_BUILD_DIR)/v6passCompat.ko
endef

define Build/Compile
#	$(MAKE) -C "$(LINUX_DIR)" \
#		$(MAKE_OPTS) \
#		modules
endef

define KernelPackage/v6passCompat/install
#	$(INSTALL_DIR) $(1)/lib/modules/3.10.14
#	$(INSTALL_BIN) $(PKG_BUILD_DIR)/v6passCompat.ko $(1)/lib/modules/3.10.14/v6passCompat.ko
endef

$(eval $(call KernelPackage,v6passCompat))
