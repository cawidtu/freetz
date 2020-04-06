$(call PKG_INIT_BIN, 486bebd9208539058e57e23a12f23103016e09b4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_CHECKSUM:=X
$(PKG)_SITE:=git@https://github.com/shadowsocks/simple-obfs.git


$(PKG)_BINARY:=$($(PKG)_DIR)/src/obfs-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/obfs-server

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG)_CONFIGURE_PRE_CMDS += AUTOGEN_SUBDIR_MODE=y ./autogen.sh ;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared --disable-documentation --disable-debug
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SIMPLEOBFS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SIMPLEOBFS_DIR) clean
	$(RM) $(EMPTY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SIMPLEOBFS_TARGET_BINARY)

$(PKG_FINISH)
