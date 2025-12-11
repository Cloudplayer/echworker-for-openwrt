include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for ECH Workers
LUCI_DESCRIPTION:=ECH (Encrypted Client Hello) Workers proxy client with smart routing
LUCI_DEPENDS:=+luci-base +ech-workers
LUCI_PKGARCH:=all

PKG_VERSION:=1.0.0
PKG_RELEASE:=2

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildance
$(eval $(call BuildPackage,luci-app-echworkers))
