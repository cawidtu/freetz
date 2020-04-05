$(call PKG_INIT_BIN, 1.15.1)
$(PKG)_SOURCE:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=ab5ed59573085e69164dce677656951d502ee6cdf0890137f6868da7af3c0ffd
$(PKG)_SITE:=https://github.com/trojan-gfw/trojan/archive/

$(PKG)_BINARY:=$($(PKG)_DIR)/trojan
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/trojan

$(PKG)_STARTLEVEL=90

$(PKG)_DEPENDS_ON += libboost openssl $(STDCXXLIB) 

$(PKG)_EXTRA_CXXFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/boost -O2 -DNDEBUG   -Wall -Wextra   -D_GLIBCXX_USE_C99 
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.cmake-run: $($(PKG)_DIR)/.unpacked
	cd $(TROJAN_DIR) && $(MAKE_ENV) cmake \
                -DCMAKE_C_COMPILER="$(TARGET_CC)"  \
                -DCMAKE_CXX_COMPILER="$(TARGET_CXX)"  \
                -DCMAKE_PREFIX_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
                -DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) $(TROJAN_EXTRA_CXXFLAGS)" \
		-DCMAKE_CXX_FLAGS_RELEASE:STRING=-O2 \
                -DCMAKE_LD_FLAGS="$(TARGET_LDFLAGS) $(TROJAN_EXTRA_LDFLAGS)" \
                -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
		-DDEFAULT_CONFIG=/var/tmp/flash/trojan/config.json
	touch $(TROJAN_DIR)/.cmake-run

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked $($(PKG)_DIR)/.cmake-run
	$(SUBMAKE) -C $(TROJAN_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TROJAN_DIR) clean
	$(RM) $(TROJAN_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TROJAN_TARGET_BINARY) 

$(PKG_FINISH)
