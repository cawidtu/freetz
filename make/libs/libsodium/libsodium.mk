$(call PKG_INIT_LIB, 1.0.17)
$(PKG)_LIB_VERSION:=1.0.17
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0f71e2680187a1558b5461e6879342c5
$(PKG)_SITE:=https://download.libsodium.org/libsodium/releases/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libsodium/.libs/$(pkg).so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-minimal
$(PKG)_CONFIGURE_OPTIONS += --disable-soname-versions
$(PKG)_CONFIGURE_OPTIONS += --disable-blocking-random --disable-documentation --disable-tests --enable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBSODIUM_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBSODIUM_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsodium.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBSODIUM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LIBSODIUM_TARGET_DIR)/libsodium*.so*

$(PKG_FINISH)
