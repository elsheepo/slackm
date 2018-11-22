#!/bin/sh

. /etc/compiler.vars

PKGNAM=llvm
VERSION=5.0.1
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-$PKGNAM

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$PKGNAM-$VERSION.src 
cd $TMP
tar xvf $CWD/$PKGNAM-$VERSION.src.tar.xz || exit 1
cd $TMP/$PKGNAM-$VERSION.src || exit 1


# We are building inside chroot, so we don't need to chown stuff
#chown -R root:root .

#patch -p1 < "$CWD"/0001-Disable-dynamic-lib-tests-for-musl-s-dlclose-is-noop.patch || exit 1
#patch -p1 < "$CWD"/cmake-fix-libLLVM-name.patch || exit 1
#patch -p1 < "$CWD"/disable-FileSystemTest.CreateDir-perms-assert.patch || exit 1
#patch -p1 < "$CWD"/dynamiclibrary-fix-build-musl.patch || exit 1
#patch -p1 < "$CWD"/fix-CheckAtomic.cmake.patch || exit 1
#patch -p1 < "$CWD"/fix-LLVMConfig-cmake-install-prefix.patch || exit 1
#patch -p1 < "$CWD"/fix-memory-mf_exec-on-aarch64.patch || exit 1

#rm test/tools/llvm-symbolizer/print_context.c

mkdir build
cd build

ffi_include_dir="$(pkg-config --cflags-only-I libffi | sed 's|^-I||g')"
cmake -Wno-dev \
	-DCMAKE_BUILD_TYPE=MinSizeRel \
	-DCMAKE_C_FLAGS_MINSIZEREL_INIT="$CFLAGS" \
	-DCMAKE_CXX_FLAGS_MINSIZEREL_INIT="$CXXFLAGS" \
	-DCMAKE_EXE_LINKER_FLAGS_MINSIZEREL_INIT="$LDFLAGS" \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DFFI_INCLUDE_DIR="$ffi_include_dir" \
	-DLLVM_BINUTILS_INCDIR=/usr/include \
	-DLLVM_BUILD_DOCS=OFF \
	-DLLVM_BUILD_EXAMPLES=OFF \
	-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_BUILD_TESTS=ON \
	-DLLVM_ENABLE_ASSERTIONS=OFF \
	-DLLVM_ENABLE_CXX1Y=ON \
	-DLLVM_ENABLE_FFI=ON \
	-DLLVM_ENABLE_LIBCXX=OFF \
	-DLLVM_ENABLE_PIC=ON \
	-DLLVM_ENABLE_RTTI=ON \
	-DLLVM_ENABLE_SPHINX=OFF \
	-DLLVM_ENABLE_TERMINFO=ON \
	-DLLVM_ENABLE_ZLIB=ON \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_TARGETS_TO_BUILD='X86;ARM;AArch64;AMDGPU' \
	-DLLVM_APPEND_VC_REV=OFF \
	../ || exit 1

make $jobs || exit 1
make install DESTDIR="$PKG" 

# Move man page directory:
mv $PKG/usr/share/man $PKG/usr/

strdoc
/sbin/makepkg -l y -c n $TMP/$PKGNAM-$VERSION-$ARCH-$BUILD.txz

