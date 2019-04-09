#
# __MSTC__, Smith, ipv6 passthrough
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mstcIpv6Pass
PKG_RELEASE:=1

ifeq ($(DUMP)$(PKG_VERSION),)
  PKG_VERSION:=0.0.0.1
endif

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mstcIpv6Pass
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Other modules
  DEPENDS:=
  TITLE:=mstc ipv6 passthrough
  FILES:=$(PKG_BUILD_DIR)/mstcIpv6Pass.ko
#  AUTOLOAD:=$(call AutoLoad,99,mtd_locked)
endef

define KernelPackage/mstcIpv6Pass/Description
This package is kernel module for ipv6 passthrough
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./files/mstcIpv6Pass.ko $(PKG_BUILD_DIR)/
endef

define Build/Compile

endef

define KernelPackage/mstcIpv6Pass/install
	$(call KernelPackage/mstcIpv6Pass/Default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mstcIpv6Pass.init $(1)/etc/init.d/mstcIpv6Pass
endef

$(eval $(call KernelPackage,mstcIpv6Pass))


