#
# __MSTC__, Smith, Set some mtd to locked
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mtd-locked
PKG_RELEASE:=1

ifeq ($(DUMP)$(PKG_VERSION),)
  PKG_VERSION:=0.0.0.1
endif

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mtd-locked
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Other modules
  DEPENDS:=
  TITLE:=change some mtd to locked
  FILES:=$(PKG_BUILD_DIR)/mtd_locked.ko
#  AUTOLOAD:=$(call AutoLoad,99,mtd_locked)
endef

define Package/kmod-mtd-locked/config
	config KMOD_MTD_LOCKED_MTD_NAME
		depends on PACKAGE_kmod-mtd-locked
		string "locked mtd name"
		default "ALL:Bootloader:Factory"
endef

MAKE_ARGS:= \
    PATH="$(TARGET_PATH)" \
    ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TOOLPREFIX="$(KERNEL_CROSS)" \
	TOOLPATH="$(KERNEL_CROSS)" \
	KERNELPATH="$(LINUX_DIR)" \
	LOCKEDMTDNAME=$(CONFIG_KMOD_MTD_LOCKED_MTD_NAME)

define KernelPackage/mtd-locked/Description
This package is kernel module for mtd locked
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/" $(MAKE_ARGS)
endef

define KernelPackage/mtd-locked/install
	$(call KernelPackage/mtd-locked/Default/install,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mstc_mtd_locked $(1)/etc/init.d/mstc_mtd_locked
endef

$(eval $(call KernelPackage,mtd-locked))

