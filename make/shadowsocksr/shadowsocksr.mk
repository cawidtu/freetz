$(call PKG_INIT_BIN, 0.8)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=5610917e6e3ea6fe4bb8c07cfdfecb22
$(PKG)_SITE:=https://github.com/ShadowsocksR-Live/shadowsocksr-native/archive/


$(PKG)_BINARY:=$($(PKG)_DIR)/src/ssr-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ssr-server
$(pkg)-cmake:=$($(PKG)_DIR)/.cmade

$(PKG)_DEPENDS_ON += mbedtls zlib pcre libuv libsodium libjson-c

$(PKG)_STARTLEVEL=90

$(PKG)_EXTRA_CFLAGS += --function-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.cmake-run: $($(PKG)_DIR)/.unpacked
	cd $(SHADOWSOCKSR_DIR) && $(MAKE_ENV) cmake \
		-DCMAKE_C_COMPILER="$(TARGET_CC)"  \
		-DCMAKE_CXX_COMPILER="$(TARGET_CXX)"  \
		-DCMAKE_PREFIX_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-DCMAKE_C_FLAGS="$(TARGET_CFLAGS) $(SHADOWSOCKSR_EXTRA_CFLAGS)" \
		-DCMAKE_LD_FLAGS="$(TARGET_LDFLAGS) $(SHADOWSOCKSR_EXTRA_LDFLAGS)" \
		-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	touch $(SHADOWSOCKSR_DIR)/.cmake-run

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked $($(PKG)_DIR)/.cmake-run
	$(SUBMAKE) -C $(SHADOWSOCKSR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHADOWSOCKSR_DIR) clean
	$(RM) $(SHADOWSOCKS_DIR)/.cmake-run
	$(RM) $(SHADOWSOCKS_DIR)/.compiled

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY) 

$(PKG_FINISH)
