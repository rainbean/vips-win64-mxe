PKG             := libde265
$(PKG)_WEBSITE  := https://www.libde265.org/
$(PKG)_DESCR    := Open h.265 video codec implementation.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.0.6
$(PKG)_CHECKSUM := e2a34ca3934a826d0893e966ee93bc2d207f505253be94ad38fb40ca98cceb5f
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/$(PKG)-[0-9]*.patch)))
$(PKG)_GH_CONF  := strukturag/libde265/releases,v
$(PKG)_DEPS     := cc mingw-std-threads

define $(PKG)_BUILD
    $(if $(WIN32_THREADS),\
        (cd '$(SOURCE_DIR)' && $(PATCH) -p1 -u) < $(realpath $(dir $(lastword $(libde265_PATCHES))))/libde265-mingw-std-threads.patch)

    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        $(if $(WIN32_THREADS),\
            -DCMAKE_CXX_FLAGS='$(CXXFLAGS) -I$(PREFIX)/$(TARGET)/include/mingw-std-threads') \
        -DDISABLE_SIMD=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
