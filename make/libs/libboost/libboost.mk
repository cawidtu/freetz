$(call PKG_INIT_LIB, 1_72_0)
$(PKG)_VERSION_DOT=1.72.0
$(PKG)_SOURCE:=boost_$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=https://dl.bintray.com/boostorg/release/$($(PKG)_VERSION_DOT)/source/

$(PKG)_SYSTEM_LIB_VERSION:=$($(PKG)_VERSION_DOT)
$(PKG)_SYSTEM_LIBNAME=libboost_system.so.$($(PKG)_SYSTEM_LIB_VERSION)
$(PKG)_SYSTEM_BINARY:=$($(PKG)_DIR)/stage/lib/$($(PKG)_SYSTEM_LIBNAME)
$(PKG)_SYSTEM_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_SYSTEM_LIBNAME)
$(PKG)_SYSTEM_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_SYSTEM_LIBNAME)

$(PKG)_PROGRAM_OPTIONS_LIB_VERSION:=$($(PKG)_VERSION_DOT)
$(PKG)_PROGRAM_OPTIONS_LIBNAME=libboost_program_options.so.$($(PKG)_PROGRAM_OPTIONS_LIB_VERSION)
$(PKG)_PROGRAM_OPTIONS_BINARY:=$($(PKG)_DIR)/stage/lib/$($(PKG)_PROGRAM_OPTIONS_LIBNAME)
$(PKG)_PROGRAM_OPTIONS_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_PROGRAM_OPTIONS_LIBNAME)
$(PKG)_PROGRAM_OPTIONS_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_PROGRAM_OPTIONS_LIBNAME)

$(PKG)_B2_OPTIONS:=toolset=gcc-mips variant=release --without-filesystem --without-serialization --without-mpi --without-context --without-python --without-mpi --without-chrono --without-context --without-wave --without-locale --without-thread --without-coroutine -j2 --without-graph_parallel --without-atomic --without-container --without-contract --without-date_time --without-fiber --without-graph --without-iostreams --without-log --without-math --without-random --without-regex --without-test --without-timer --without-type_erasure --without-exception --without-stacktrace address-model=32 architecture=mips32

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.bootstrap-run: $($(PKG)_DIR)/.configured
	cd $(LIBBOOST_DIR) &&  \
		./bootstrap.sh ; \
		echo "using gcc : mips : $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/mips-linux-g++ ;" >> project-config.jam ; \
		touch .bootstrap-run

$($(PKG)_SYSTEM_BINARY) $($(PKG)_PROGRAM_OPTIONS_BINARY): $(LIBBOOST_DIR)/.bootstrap-run $(LIBBOOST_DIR)/.configured
	cd $(LIBBOOST_DIR) && \
	PATH=$(TARGET_PATH) \
		./b2 $(LIBBOOST_B2_OPTIONS)\
		cflags="$(TARGET_CFLAGS)" cxxflags="$(TARGET_CFLAGS)" \
		include=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include --prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr 
	

$($(PKG)_SYSTEM_STAGING_BINARY) $($(PKG)_PROGRAM_OPTIONS_STAGING_BINARY): $($(PKG)_SYSTEM_BINARY) $($(PKG)_PROGRAM_OPTIONS_BINARY) 
	cd $(LIBBOOST_DIR) && PATH=$(TARGET_PATH) \
		./b2 $(LIBBOOST_B2_OPTIONS)\
                cflags="$(TARGET_CFLAGS)" cxxflags="$(TARGET_CFLAGS)" \
                include=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include --prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr install

$($(PKG)_SYSTEM_TARGET_BINARY): $($(PKG)_SYSTEM_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libboost_system*.so* $(LIBBOOST_TARGET_DIR)/ 
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_PROGRAM_OPTIONS_TARGET_BINARY): $($(PKG)_PROGRAM_OPTIONS_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libboost_program_options*.so* $(LIBBOOST_TARGET_DIR)/ 
	$(INSTALL_LIBRARY_STRIP) 


$(pkg): $($(PKG)_SYSTEM_STAGING_BINARY) $($(PKG)_PROGRAM_OPTIONS_STAGING_BINARY) 

$(pkg)-precompiled: $($(PKG)_SYSTEM_TARGET_BINARY) $($(PKG)_PROGRAM_OPTIONS_TARGET_BINARY)

$(pkg)-clean:
	$(LIBBOOST_DIR)/b2 toolset=gcc-mips --clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libboost*.* 
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/boost

$(pkg)-uninstall:
	$(RM) $(LIBBOOST_TARGET_DIR)/libboost*.so*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/boost


$(PKG_FINISH)
