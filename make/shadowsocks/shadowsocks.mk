$(call PKG_INIT_BIN, 0.0.1)
$(PKG)_SOURCE:=shadowsocks-libev-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ddaf810c98bebbf1778dd802184f4b3f
$(PKG)_SITE:=https://github.com/owsocks/shadowsocks-libev/releases/download/v$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/ss-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ss-server
$(PKG)_EXTRA_CFLAGS += --function-section -fdata-sections -fstack-protector-strong
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG)_CONFIGURE_OPTIONS += --enable-shared --disable-documentation --disable-debug --disable-ssp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG)_CONFIGURE_PRE_CMDS += AUTOGEN_SUBDIR_MODE=y ./autogen.sh ;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SHADOWSOCKS_DIR) \
		EXTRA_CFLAGS="$(SHADOWSOCKS_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(SHADOWSOCKS_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHADOWSOCKS_DIR) clean
	$(RM) $(SHADOWSOCKS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SHADOWSOCKS_TARGET_BINARY) 

$(PKG_FINISH)
