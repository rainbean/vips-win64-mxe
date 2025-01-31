# MXE will run as many parallel jobs as there are available CPU
# cores. This variable can limit this.
#JOBS := 4

# MXE stores intermediate files in the current directory by
# default. Store them in /var/tmp instead to ensure git commands
# are no-op.
MXE_TMP := /var/tmp

# Turn on debugging
export CFLAGS   := -g -Og -fdata-sections -ffunction-sections
export CXXFLAGS := -g -Og -fdata-sections -ffunction-sections
export LDFLAGS  := -Wl,--gc-sections -Wl,-lucrtbased

# Clang produces debug info in DWARF format by default.
# To debug with WinDbg (PDB format) use:
#export CFLAGS   := -g -gcodeview
#export CXXFLAGS := -g -gcodeview
#export LDFLAGS  := -Wl,--pdb=
# (see: https://github.com/mstorsjo/llvm-mingw/blob/master/README.md#pdb-support)

# Special flags for Rust.
export CARGO_PROFILE_RELEASE_DEBUG         := true
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS := 1
export CARGO_PROFILE_RELEASE_INCREMENTAL   := false
export CARGO_PROFILE_RELEASE_LTO           := true
export CARGO_PROFILE_RELEASE_OPT_LEVEL     := 1
export CARGO_PROFILE_RELEASE_PANIC         := abort

# We need debugging symbols.
STRIP_TOOLCHAIN := $(false)
STRIP_LIB       := $(false)
STRIP_EXE       := $(false)

# Disable ccache
MXE_USE_CCACHE := $(false)
