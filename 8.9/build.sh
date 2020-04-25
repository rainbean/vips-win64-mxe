#!/usr/bin/env bash

# exit on error
set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 [DEPS] [TARGET]"
  echo "Build libvips for win"
  echo "DEPS is the group of dependencies to build libvips with,"
  echo "    defaults to 'web'"
  echo "TARGET is the binary target,"
  echo "    defaults to 'x86_64-w64-mingw32.shared.win32'"
  exit 1
fi

. variables.sh

deps="${1:-web}"
target="${2:-x86_64-w64-mingw32.shared.win32}"

# Always checkout a particular revision which will successfully build.
# This ensures that it will not suddenly break a build.
# Note: Must be regularly updated.
revision="951c528c4e75fca058f491f0894fdb389294b61c"
initialize=false

if [ -f "$mxe_dir/Makefile" ]; then
  echo "Skip cloning, MXE already exists at $mxe_dir"
  cd $mxe_dir && git fetch
else
  git clone https://github.com/mxe/mxe && cd $mxe_dir
  initialize=true
fi

curr_revision=$(git rev-parse HEAD)

# Is our branch up-to-date?
if [ ! "$curr_revision" = "$revision" ]; then
  git pull && git reset --hard $revision
  initialize=true
fi

if [ "$initialize" = true ] ; then
  # Patch MXE to support the ARM/ARM64 targets
  git apply $work_dir/plugins/llvm-mingw/patches/mxe-fixes.patch
fi

# The 'plugins' variable controls which plugins are in use.
if [ "$LLVM" = "true" ]; then
  plugins="$work_dir/plugins/llvm-mingw"

  # Copy LLVM settings
  cp -f $work_dir/settings/llvm.mk $mxe_dir/settings.mk
  cp -f $work_dir/settings/meson-llvm.in $mxe_dir/plugins/meson-wrapper/conf/mxe-crossfile.meson.in
else
  # Build with GCC 9.3
  plugins="plugins/gcc9"

  # Copy GCC settings
  cp -f $work_dir/settings/gcc.mk $mxe_dir/settings.mk
  cp -f $work_dir/settings/meson-gcc.in $mxe_dir/plugins/meson-wrapper/conf/mxe-crossfile.meson.in
fi

# Use the meson-wrapper and our custom overrides
plugins+=" plugins/meson-wrapper $work_dir"

if [ "$MOZJPEG" = "true" ]; then
  plugins+=" $work_dir/plugins/mozjpeg"
fi

# Prepare MinGW directories
mkdir -p $mxe_prefix/$target.$deps/mingw/{bin,include,lib}

# Build pe-util, handy for copying DLL dependencies.
make pe-util \
  IGNORE_SETTINGS=yes \
  MXE_TARGETS=`$mxe_dir/ext/config.guess`

# Build MXE's meson-wrapper (needed by pango, GDK-PixBuf, GLib and Orc), 
# gendef (a tool for generating def files from DLLs)
# and libvips (+ dependencies).
make meson-wrapper gendef vips-$deps \
  MXE_PLUGIN_DIRS="$plugins" \
  MXE_TARGETS=$target.$deps

# Build and bundle llvm-mingw tests
if [ "$LLVM" = "true" ]; then
  make test-llvm-mingw \
    MXE_PLUGIN_DIRS="$plugins" \
    MXE_TARGETS=$target.$deps
fi

cd $work_dir

# Packaging
. $work_dir/package-vipsdev.sh $deps $target
