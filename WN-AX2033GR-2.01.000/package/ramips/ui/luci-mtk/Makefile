include $(TOPDIR)/rules.mk

LUCI_TOPDIR=src

PKG_NAME:=luci
PKG_RELEASE:=1

PKG_BUILD_PARALLEL:=0

PKG_VERSION:=$(shell $(LUCI_TOPDIR)/build/mkrevision.sh 2>/dev/null || echo unknown)

PKG_BUILD_DEPENDS:=$(if $(STAGING_DIR_ROOT),lua/host) iwinfo
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install
PKG_USE_MIPS16:=0

LUA_TARGET:=source
LUCI_CFLAGS:=
LUCI_BUILD_PACKAGES:=
LUCI_SELECTED_MODULES:=

ifeq ($(BOARD),brcm-2.4)
  MAKE_FLAGS += CRAP="1"
endif


### Templates ###
define Package/luci/install/template
	$(CP) -a $(PKG_BUILD_DIR)/$(2)/dist/* $(1)/ -R
	$(CP) -a $(PKG_BUILD_DIR)/$(2)/ipkg/* $(1)/CONTROL/ 2>/dev/null || true
endef


### Core package ###
define Package/luci-base
  SECTION:=luci
  CATEGORY:=LuCI(MTK)
  TITLE:=LuCI - Lua Configuration Interface
  URL:=http://luci.subsignal.org/
  MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
  SUBMENU:=8. Libraries
  DEPENDS:=+lua +libuci-lua +libubus-lua
  TITLE:=LuCI core libraries
endef

define Package/luci-base/install
	$(call Package/luci/install/template,$(1),modules/base)
	$(PKG_BUILD_DIR)/build/mkversion.sh $(1)/usr/lib/lua/luci/version.lua \
		"OpenWrt Firmware" \
		"$(OPENWRTVERSION)" \
		"trunk" \
		"$(PKG_VERSION)"
endef

define Package/luci-base/config
       choice
               prompt "Build Target"
               default PACKAGE_luci-base_source

       config PACKAGE_luci-base_compile
               bool "Precompiled"

       config PACKAGE_luci-base_stripped
               bool "Stripped"

       config PACKAGE_luci-base_srcdiet
               bool "Compressed Source"

       config PACKAGE_luci-base_source
               bool "Full Source"

       endchoice
endef

define Package/luci-base/conffiles
/etc/config/luci
endef

ifneq ($(CONFIG_PACKAGE_luci-base_compile),)
  LUA_TARGET:=compile
endif

ifneq ($(CONFIG_PACKAGE_luci-base_stripped),)
  LUA_TARGET:=strip
endif

ifneq ($(CONFIG_PACKAGE_luci-base_srcdiet),)
  LUA_TARGET:=diet
endif

ifneq ($(CONFIG_PACKAGE_luci-base),)
  LUCI_SELECTED_MODULES+=modules/base
endif

LUCI_BUILD_PACKAGES += luci-base


### Libraries ###
define library
  define Package/luci-lib-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=8. Libraries
    TITLE:=$(if $(2),$(2),LuCI $(1) library)
    $(if $(3),DEPENDS:=+luci-base $(3))
  endef

  define Package/luci-lib-$(1)/install
	$(call Package/luci/install/template,$$(1),libs/$(1))
	$(call Package/luci-lib-$(1)/extra-install)
  endef

  ifneq ($(CONFIG_PACKAGE_luci-lib-$(1)),)
    LUCI_SELECTED_MODULES+=libs/$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-lib-$(1)
endef

define Package/luci-lib-nixio/config
	choice
		prompt "TLS Provider"
		default PACKAGE_luci-lib-nixio_notls

		config PACKAGE_luci-lib-nixio_notls
			bool "Disabled"

		config PACKAGE_luci-lib-nixio_axtls
			bool "Builtin (axTLS)"

		config PACKAGE_luci-lib-nixio_cyassl
			bool "CyaSSL"
			select PACKAGE_libcyassl

		config PACKAGE_luci-lib-nixio_openssl
			bool "OpenSSL"
			select PACKAGE_libopenssl
	endchoice
endef


NIXIO_TLS:=

ifneq ($(CONFIG_PACKAGE_luci-lib-nixio_axtls),)
  NIXIO_TLS:=axtls
endif

ifneq ($(CONFIG_PACKAGE_luci-lib-nixio_openssl),)
  NIXIO_TLS:=openssl
endif

ifneq ($(CONFIG_PACKAGE_luci-lib-nixio_cyassl),)
  NIXIO_TLS:=cyassl
  LUCI_CFLAGS+=-I$(STAGING_DIR)/usr/include/cyassl
endif


$(eval $(call library,httpclient,HTTP(S) client library,+luci-base +luci-lib-nixio))
$(eval $(call library,json,LuCI JSON library))
$(eval $(call library,nixio,NIXIO POSIX library,+PACKAGE_luci-lib-nixio_openssl:libopenssl +PACKAGE_luci-lib-nixio_cyassl:libcyassl))
$(eval $(call library,px5g,RSA/X.509 Key Generator (required for LuCId SSL support),+luci-lib-nixio))
$(eval $(call library,luaneightbl,neightbl - Lua lib for IPv6 neighbors,+luci-base))

#MSTC, Sean, Add mstc-luci-utils
$(eval $(call library,mstc-luci-utils,MSTC Luci utils,+luci-base))
#End

### Protocols ###
define protocol
  define Package/luci-proto-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=6. Protocols
    TITLE:=$(if $(2),$(2),LuCI $(1) protocol support)
    DEPENDS:=$(3)
  endef

  define Package/luci-proto-$(1)/install
	$(call Package/luci/install/template,$$(1),protocols/$(1))
  endef

  ifneq ($(CONFIG_PACKAGE_luci-proto-$(1)),)
    LUCI_SELECTED_MODULES+=protocols/$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-proto-$(1)
endef

$(eval $(call protocol,ppp,Support for PPP/PPPoE/PPPoA/PPtP))
$(eval $(call protocol,ipv6,Support for DHCPv6/6in4/6to4/6rd/DS-Lite))
$(eval $(call protocol,3g,Support for 3G,+PACKAGE_luci-proto-3g:comgt))
$(eval $(call protocol,relay,Support for relayd pseudo bridges,+PACKAGE_luci-proto-relay:relayd))


### Modules ###
define module
  define Package/luci-mod-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=2. Modules
    TITLE:=$(if $(2),$(2),LuCI $(1) module)
    $(if $(3),DEPENDS+=$(3))
  endef

  define Package/luci-mod-$(1)/install
	$(call Package/luci/install/template,$$(1),modules/$(1))
	$(call Package/luci-mod-$(1)/extra-install)
  endef

  ifneq ($(CONFIG_PACKAGE_luci-mod-$(1)),)
    LUCI_SELECTED_MODULES+=modules/$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-mod-$(1)
endef


$(eval $(call module,admin-mini,LuCI Essentials - stripped down and user-friendly,+luci-base @BROKEN))
$(eval $(call module,admin-full,LuCI Administration - full-featured for full control,+luci-base))
$(eval $(call module,failsafe,LuCI Fail-Safe - Fail-Safe sysupgrade module,+luci-base))
$(eval $(call module,rpc,LuCI RPC - JSON-RPC API,+luci-lib-json))
# MSTC, Sharon, Add modules admin-core and admin-expert
#$(eval $(call module,admin-core,Web UI Core Module,+luci-base))
#$(eval $(call module,admin-expert, Expert mode,+luci-base))
#$(eval $(call module,dashboard, Dashboard,+luci-base))
#$(eval $(call module,monitor, Monitor,+luci-base))
#$(eval $(call module,configuration, Configuration,+luci-base))
#$(eval $(call module,maintenance, Maintenance,+luci-base))
# End

#MSTC, Sean, Add IODATA module
$(eval $(call module,iodata-advanced_settings,IODATA Adavnced Settings page module,+luci-base))
$(eval $(call module,iodata-easy_connection,IODATA Easy Connection page module,+luci-base))
$(eval $(call module,iodata-redirect,IODATA redirect to home page module,+luci-base))
$(eval $(call module,iodata-index,IODATA Index page module,+luci-base +luci-lib-mstc-luci-utils))
$(eval $(call module,iodata-internet,IODATA Internet page module,+luci-base))
$(eval $(call module,iodata-net_filtering,IODATA Net Filtering page module,+luci-base))
$(eval $(call module,iodata-lan_settings,IODATA Lan Settings page module,+luci-base))
$(eval $(call module,iodata-parental_control,IODATA Parental Control page module,+luci-base))
$(eval $(call module,iodata-status,IODATA Status page module,+luci-base))
$(eval $(call module,iodata-system_settings,IODATA System Settings page module,+luci-base))
$(eval $(call module,iodata-vpn,IODATA VPN page module,+luci-base))
$(eval $(call module,iodata-wireless_settings,IODATA Wireless Settings page module,+luci-base))
$(eval $(call module,iodata-security,IODATA Security page module,+luci-base))
$(eval $(call module,iodata-ioswinf,IODATA Secret page for inspection module,+luci-base))
#End

#MSTC, Olivia, Add MSTC module
$(eval $(call module,mstc-advanced_settings,MSTC Adavnced Settings page module,+luci-base))
$(eval $(call module,mstc-easy_connection,MSTC Easy Connection page module,+luci-base))
$(eval $(call module,mstc-redirect,MSTC redirect to home page module,+luci-base))
$(eval $(call module,mstc-index,MSTC Index page module,+luci-base +luci-lib-mstc-luci-utils))
$(eval $(call module,mstc-internet,MSTC Internet page module,+luci-base))
$(eval $(call module,mstc-net_filtering,MSTC Net Filtering page module,+luci-base))
$(eval $(call module,mstc-lan_settings,MSTC Lan Settings page module,+luci-base))
$(eval $(call module,mstc-parental_control,MSTC Parental Control page module,+luci-base))
$(eval $(call module,mstc-status,MSTC Status page module,+luci-base))
$(eval $(call module,mstc-system_settings,MSTC System Settings page module,+luci-base))
$(eval $(call module,mstc-vpn,MSTC VPN page module,+luci-base))
$(eval $(call module,mstc-wireless_settings,MSTC Wireless Settings page module,+luci-base))
$(eval $(call module,mstc-security,MSTC Security page module,+luci-base))
$(eval $(call module,mstc-ioswinf,MSTC Secret page for inspection module,+luci-base))
$(eval $(call module,mstc-usb,MSTC USB page,+luci-base))
#End

#MSTC, Sean, add csrf page 
$(eval $(call module,mstc-csrf,csrf pages user can get csrf token here,+luci-base))

#MSTC, Olivia,Add IODATA Mobile modules
$(eval $(call module,iodata-mobile-status,IODATA Mobile Status,+luci-base))
$(eval $(call module,iodata-mobile-internet,IODATA Internet Setting Page,+luci-base))
$(eval $(call module,iodata-mobile-wireless-basic,IODATA Wireless Setting Page,+luci-base))
$(eval $(call module,iodata-mobile-ezinet,IODATA Mobile Easy Connetion Setting Page,+luci-base))
$(eval $(call module,iodata-mobile-netfilter,IODATA Net Filtering Setting Page,+luci-base))
$(eval $(call module,iodata-mobile-family,IODATA PC Setting Page,+luci-base))
#End

#End

### Applications ###
define application
  define Package/luci-app-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=3. Applications
    TITLE:=$(if $(2),$(2),LuCI $(1) application)
	DEPENDS:=$(3)
  endef

  define Package/luci-app-$(1)/install
	$(call Package/luci/install/template,$$(1),applications/luci-$(1))
  endef

  ifneq ($(CONFIG_PACKAGE_luci-app-$(1)),)
    LUCI_SELECTED_MODULES+=applications/luci-$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-app-$(1)
endef

/* __MSTC__, Vincent: Enable luci-app-upnp in MTK OpenWrt luci-mtk package*/
$(eval $(call application,upnp,Universal Plug & Play configuration module,\
	+PACKAGE_luci-app-upnp:upnp))

$(eval $(call application,firewall,Firewall and Portforwarding application,\
	+PACKAGE_luci-app-firewall:firewall))

$(eval $(call application,qos,Quality of Service configuration module,\
	+PACKAGE_luci-app-qos:qos-scripts))

$(eval $(call application,commands,LuCI Shell Command Module))
# MSTC, Sharon, Add applications for common GUI structure
$(eval $(call application,monitor-log,MSTC Support for Log))
$(eval $(call application,monitor-dhcp-table,MSTC Support for DHCP Table))
$(eval $(call application,monitor-internet-status,MSTC Support for Internet Status))
$(eval $(call application,monitor-sms,MSTC Support for SMS))
$(eval $(call application,maintenance-password,MSTC Support for Password))
$(eval $(call application,maintenance-fw-upgrade,MSTC Support for Firmware Upgrade))
$(eval $(call application,maintenance-backup-restore,MSTC Support for Backup/Restore))
$(eval $(call application,maintenance-restart,MSTC Support for Restart))
$(eval $(call application,maintenance-language,MSTC Support for Language))
$(eval $(call application,maintenance-oled-display,MSTC Support for OLED Display))
$(eval $(call application,configuration-sim,MSTC Support for SIM))
$(eval $(call application,configuration-network-settings,MSTC Support for Network Settings))
$(eval $(call application,configuration-lan,MSTC Support for LAN))
$(eval $(call application,configuration-wlan,MSTC Support for WLAN))
$(eval $(call application,configuration-dmz,MSTC Support for DMZ))
$(eval $(call application,configuration-apn,MSTC Support for APN))
$(eval $(call application,help,LuCI Support for Help,help))
# end

# MSTC, Sean, Add applications for IODATA GUI structure
$(eval $(call application,iodata-lan_settings-dhcp,IODATA support for Lan Settings-DHCP page))
$(eval $(call application,iodata-lan_settings-ipaddress_settings,IODATA support for Lan Settings-IP address Settings page))
$(eval $(call application,iodata-wireless_settings-2g_settings,IODATA support for Wireless Settings-2.4g Settings page))
$(eval $(call application,iodata-wireless_settings-5g_settings,IODATA support for Wireless Settings-5g Settings page))
$(eval $(call application,iodata-wireless_settings-advanced_settings,IODATA support for Wireless Settings-Advanced Settings page))
$(eval $(call application,iodata-wireless_settings-mac_filter,IODATA support for Wireless Settings-MAC Filter page))
$(eval $(call application,iodata-wireless_settings-wps,IODATA support for Wireless Settings-WPS page))
$(eval $(call application,iodata-wireless_settings-client_list,IODATA support for Wireless Settings-Client List page))
$(eval $(call application,iodata-wireless_settings-repeater_connection_setup,IODATA support for Wireless Settings-Repeater Setup page))
$(eval $(call application,iodata-security-passthrough,IODATA support for Security-Passthrough page))
$(eval $(call application,iodata-security-dmz,IODATA support for Security-DMZ page))
$(eval $(call application,iodata-security-dos,IODATA support for Security-DoS page))
$(eval $(call application,iodata-security-spi,IODATA support for Security-SPI page))
$(eval $(call application,iodata-security-dos-ipv6-spi,IODATA support for Security-Dos &IPv6 SPI page))
$(eval $(call application,iodata-vpn-status,IODATA support for VPN-Status page))
$(eval $(call application,iodata-vpn-pptp_settings,IODATA support for PPTP Settings page))
$(eval $(call application,iodata-advanced_settings-port_forwarding,IODATA support for Advanced Settings-Ports Forwarding page))
$(eval $(call application,iodata-advanced_settings-upnp,IODATA support for Advanced Settings-UPnP page))
$(eval $(call application,iodata-advanced_settings-lamp,IODATA support for Advanced Settings-lamp page))
$(eval $(call application,iodata-advanced_settings-iobbnet,IODATA support for Advanced Settings-iobb.NET page))
$(eval $(call application,iodata-advanced_settings-nat,IODATA support for Advanced Settings-NAT page))
$(eval $(call application,iodata-advanced_settings-easy_connection,IODATA support for Advanced Settings-Easy Connection page))
$(eval $(call application,iodata-advanced_settings-eee,IODATA support for Advanced Settings-EEE page))
$(eval $(call application,iodata-net_filtering-net_filtering,IODATA support for Net Filtering-Net Filtering page))
$(eval $(call application,iodata-net_filtering-individual_settings,IODATA support for Net Filtering-Individual Settings page))
$(eval $(call application,iodata-net_filtering-url_filter,IODATA support for Net Filtering-URL Filter page))
$(eval $(call application,iodata-net_filtering-block_log,IODATA support for Net Filtering-Block log))
$(eval $(call application,iodata-net_filtering-warning,IODATA support for Net Filtering-Warning))
$(eval $(call application,iodata-parental_control-time_limit,IODATA support for Parental Control-Time Limit page))
$(eval $(call application,iodata-parental_control-site_limit,IODATA support for Parental Control-Site Limit page))
$(eval $(call application,iodata-system_settings-password_settings,IODATA support for System Settings-Password Settings page))
$(eval $(call application,iodata-system_settings-time_settings,IODATA support for System Settings-Time Settings page))
$(eval $(call application,iodata-system_settings-log,IODATA support for System Settings-Log page))
$(eval $(call application,iodata-system_settings-firmware,IODATA support for System Settings-Firmware page))
$(eval $(call application,iodata-system_settings-backup,IODATA support for System Settings-Backup page))
$(eval $(call application,iodata-system_settings-initialization,IODATA support for System Settings-Initialization page))
#end

# MSTC, Olivia, Add applications for MSTC GUI structure
$(eval $(call application,mstc-lan_settings-dhcp,MSTC support for Lan Settings-DHCP page))
$(eval $(call application,mstc-lan_settings-ipaddress_settings,MSTC support for Lan Settings-IP address Settings page))
$(eval $(call application,mstc-wireless_settings-2g_settings,MSTC support for Wireless Settings-2.4g Settings page))
$(eval $(call application,mstc-wireless_settings-5g_settings,MSTC support for Wireless Settings-5g Settings page))
$(eval $(call application,mstc-wireless_settings-advanced_settings,MSTC support for Wireless Settings-Advanced Settings page))
$(eval $(call application,mstc-wireless_settings-mac_filter,MSTC support for Wireless Settings-MAC Filter page))
$(eval $(call application,mstc-wireless_settings-wps,MSTC support for Wireless Settings-WPS page))
$(eval $(call application,mstc-wireless_settings-client_list,MSTC support for Wireless Settings-Client List page))
$(eval $(call application,mstc-wireless_settings-repeater_connection_setup,MSTC support for Wireless Settings-Repeater Setup page))
$(eval $(call application,mstc-security-passthrough,MSTC support for Security-Passthrough page))
$(eval $(call application,mstc-security-dmz,MSTC support for Security-DMZ page))
$(eval $(call application,mstc-security-dos,MSTC support for Security-DoS page))
$(eval $(call application,mstc-security-spi,MSTC support for Security-SPI page))
$(eval $(call application,mstc-vpn-status,MSTC support for VPN-Status page))
$(eval $(call application,mstc-vpn-pptp_settings,MSTC support for PPTP Settings page))
$(eval $(call application,mstc-advanced_settings-port_forwarding,MSTC support for Advanced Settings-Ports Forwarding page))
$(eval $(call application,mstc-advanced_settings-upnp,MSTC support for Advanced Settings-UPnP page))
$(eval $(call application,mstc-advanced_settings-lamp,MSTC support for Advanced Settings-lamp page))
$(eval $(call application,mstc-advanced_settings-iobbnet,MSTC support for Advanced Settings-iobb.NET page))
$(eval $(call application,mstc-advanced_settings-nat,MSTC support for Advanced Settings-NAT page))
$(eval $(call application,mstc-advanced_settings-easy_connection,MSTC support for Advanced Settings-Easy Connection page))
$(eval $(call application,mstc-advanced_settings-eee,MSTC support for Advanced Settings-EEE page))
$(eval $(call application,mstc-net_filtering-net_filtering,MSTC support for Net Filtering-Net Filtering page))
$(eval $(call application,mstc-net_filtering-individual_settings,MSTC support for Net Filtering-Individual Settings page))
$(eval $(call application,mstc-net_filtering-url_filter,MSTC support for Net Filtering-URL Filter page))
$(eval $(call application,mstc-net_filtering-block_log,MSTC support for Net Filtering-Block log))
$(eval $(call application,mstc-net_filtering-warning,MSTC support for Net Filtering-Warning))
$(eval $(call application,mstc-parental_control-time_limit,MSTC support for Parental Control-Time Limit page))
$(eval $(call application,mstc-parental_control-site_limit,MSTC support for Parental Control-Site Limit page))
$(eval $(call application,mstc-system_settings-password_settings,MSTC support for System Settings-Password Settings page))
$(eval $(call application,mstc-system_settings-time_settings,MSTC support for System Settings-Time Settings page))
$(eval $(call application,mstc-system_settings-log,MSTC support for System Settings-Log page))
$(eval $(call application,mstc-system_settings-firmware,MSTC support for System Settings-Firmware page))
$(eval $(call application,mstc-system_settings-backup,MSTC support for System Settings-Backup page))
$(eval $(call application,mstc-system_settings-initialization,MSTC support for System Settings-Initialization page))
$(eval $(call application,mstc-usb-usb_settings,MSTC support for USB default setting page))
#end

### Themes ###
define theme
  define Package/luci-theme-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    SUBMENU:=4. Themes
    TITLE:=$(if $(2),$(2),LuCI $(1) theme)
    MAINTAINER:=$(if $(3),$(3),LuCI Development Team <luci@lists.subsignal.org>)
  endef

  define Package/luci-theme-$(1)/install
	$(call Package/luci/install/template,$$(1),themes/$(1))
  endef

  ifneq ($(CONFIG_PACKAGE_luci-theme-$(1)),)
    LUCI_SELECTED_MODULES+=themes/$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-theme-$(1)
endef

$(eval $(call theme,openwrt,OpenWrt.org))
$(eval $(call theme,bootstrap,Bootstrap Theme (default)))
# MSTC, Sharon, Add theme base and mitrastar
$(eval $(call theme,base,Common base for all themes))
$(eval $(call theme,mstc,MitraStar proprietary web page design))
#end
#MSTC Sean, Add theme iodata
$(eval $(call theme,iodata,IO-DATA Theme))

### Translations ###
define translation
  define Package/luci-i18n-$(1)
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=5. Translations
    TITLE:=$(if $(2),$(2),$(1))
  endef

  define Package/luci-i18n-$(1)/install
	#MSTC MBA sean, remove the unnecessary file
	rm -rf $(PKG_BUILD_DIR)/i18n/$(1)/dist/usr/lib/lua/luci/i18n/*.lua
	$(call Package/luci/install/template,$$(1),i18n/$(1))
  endef

  ifneq ($(CONFIG_PACKAGE_luci-i18n-$(1)),)
    LUCI_SELECTED_MODULES+=i18n/$(1)
  endif

  LUCI_BUILD_PACKAGES += luci-i18n-$(1)
endef

$(eval $(call translation,german,German))
$(eval $(call translation,english,English))
$(eval $(call translation,french,French (by Florian Fainelli)))
$(eval $(call translation,italian,Italian (by Matteo Croce)))
$(eval $(call translation,russian,Russian (by Skryabin Dmitry)))
#$(eval $(call translation,portuguese-brazilian,Portuguese (Brazilian) (by Carlos Cesario)))
$(eval $(call translation,chinese,Chinese (by Chinese Translators)))
$(eval $(call translation,japanese,Japanese (by Tsukasa Hamano)))
#$(eval $(call translation,greek,Greek (by Vasilis Tsiligiannis)))
#$(eval $(call translation,catalan,Catalan (by Eduard Duran)))
#$(eval $(call translation,portuguese,Portuguese (by Jose Monteiro)))
#$(eval $(call translation,spanish,Spanish (by Guillermo Javier Nardoni)))
#$(eval $(call translation,vietnamese,Vietnamese (by Hong Phuc Dang)))
#$(eval $(call translation,malay,Malay (by Teow Wai Chet)))
#$(eval $(call translation,norwegian,Norwegian (by Lars Hardy)))
#$(eval $(call translation,hebrew,Hebrew))
#$(eval $(call translation,romanian,Romanian))
#$(eval $(call translation,ukrainian,Ukrainian))
#$(eval $(call translation,hungarian,Hungarian))
#$(eval $(call translation,polish,Polish))


### Collections ###
define collection
  define Package/luci$(if $(1),-$(1))
    SECTION:=luci
    CATEGORY:=LuCI(MTK)
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=1. Collections
    TITLE:=$(if $(2),$(2),LuCI $(if $(1),$(1),general) collection)
    $(if $(3),DEPENDS:=$(3))
  endef

  define Package/luci$(if $(1),-$(1))/install
	true
  endef

  LUCI_BUILD_PACKAGES += luci$(if $(1),-$(1))
endef

# MSTC, YaoTien, remove dependent package uhttpd and uhttpd-mod-ubus
#$(eval $(call collection,,\
	Standard OpenWrt set including full admin with ppp support and the \
	default OpenWrt theme,\
	+uhttpd +uhttpd-mod-ubus +luci-mod-admin-full +luci-theme-bootstrap \
	+luci-app-firewall +luci-proto-ppp +libiwinfo-lua-2014-10-27.1 +luci-lib-nixio))
$(eval $(call collection,,\
	Standard OpenWrt set including full admin with ppp support and the \
	default OpenWrt theme,\
	+luci-app-firewall +luci-proto-ppp +libiwinfo-lua-2014-10-27.1 +luci-lib-nixio))
# End of remove dependent package uhttpd and uhttpd-mod-ubus

$(eval $(call collection,ssl,\
	Standard OpenWrt set with HTTPS support,\
	+luci +libustream-polarssl +px5g))

# MSTC, YaoTien, remove dependent package uhttpd
#$(eval $(call collection,light,\
	Minimum package set using only admin mini and the standard theme,\
	+uhttpd +luci-mod-admin-mini +luci-theme-openwrt @BROKEN))
$(eval $(call collection,light,\
	Minimum package set using only admin mini and the standard theme,\
	+luci-mod-admin-mini +luci-theme-openwrt @BROKEN))
# End of remove dependent package uhttpd


### Compile ###
PKG_CONFIG_DEPENDS=$(patsubst %,CONFIG_PACKAGE_%,$(LUCI_BUILD_PACKAGES))

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	pwd
	echo $(LUCI_TOPDIR)/build/mkrevision.sh
	mkdir -p $(LUCI_TOPDIR)/huahua/
	@if [ ! -x $(LUCI_TOPDIR)/build/mkrevision.sh ]; then \
		echo "*** Repository layout changed!" >&2; \
		echo "*** Please change the LuCI url in feeds.conf to http://svn.luci.subsignal.org/luci/trunk and reinstall the feed with" >&2; \
		echo "*** ./scripts/feeds update luci; ./scripts/feeds install -a -p luci" >&2; \
		exit 1; \
	fi
	mkdir -p $(PKG_BUILD_DIR)
	pwd
	$(TAR) c -C $(LUCI_TOPDIR) . \
		--exclude=.pc --exclude=.svn --exclude=.git \
		--exclude='*.o' --exclude='*.so' \
		--exclude=dist | \
			tar x -C $(PKG_BUILD_DIR)/
	$(call Build/Prepare/Default)
endef

define Build/Configure
endef

MAKE_FLAGS += \
	MODULES="$(LUCI_SELECTED_MODULES)" \
	LUA_TARGET="$(LUA_TARGET)" \
	LUA_SHLIBS="-llua -lm -ldl -lcrypt" \
	CFLAGS="$(TARGET_CFLAGS) $(LUCI_CFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib" \
	NIXIO_TLS="$(NIXIO_TLS)" OS="Linux"


$(foreach b,$(LUCI_BUILD_PACKAGES),$(eval $(call BuildPackage,$(b))))
