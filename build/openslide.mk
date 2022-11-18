PKG             := openslide
$(PKG)_WEBSITE  := https://openslide.org/
$(PKG)_DESCR    := C library for reading virtual slide images.
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.4.1
$(PKG)_TAG_REF  := 2022-11-18
$(PKG)_CHECKSUM := 73a5eb30a2201242bf9eb0f424eef03a6fc7f049e76f82f28186d8f2b1c5c143
$(PKG)_PATCHES  := $(realpath $(sort $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))/patches/$(PKG)-[0-9]*.patch)))
$(PKG)_GH_CONF  := openslide/openslide/releases
$(PKG)_DEPS     := cc zlib cairo gdk-pixbuf libjpeg-turbo tiff openjpeg sqlite

define $(PKG)_BUILD
    # This can be removed once the patch "openslide-3-fixes.patch" is accepted by upstream
    cd '$(SOURCE_DIR)' && autoreconf -fi -I'$(PREFIX)/$(TARGET)/share/aclocal'

    # Allow libtool to statically link against libintl
    # by specifying lt_cv_deplibs_check_method="pass_all"
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS) \
        $(if $(IS_INTL_DUMMY), lt_cv_deplibs_check_method="pass_all")

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 $(INSTALL_STRIP_LIB) $(MXE_DISABLE_CRUFT)
endef
