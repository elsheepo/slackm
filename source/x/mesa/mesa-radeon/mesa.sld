#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

# Requires freeglut, glu and glew packages in source/x
# Also dri2proto in source/x/proto

BUILD=3
APP=mesa
VERSION=18.2.4
DEMOVERS=8.3.0
PKG=$TMP/package-$APP

# Be sure this list is up-to-date:
DRI_DRIVERS="i915,i965,nouveau,r200,radeon,swrast"
GALLIUM_DRIVERS="nouveau,radeonsi,r300,r600,swrast"

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

# workaround for missing endian-ness defines taken from alpine linux
endian="LITTLEENDIAN_CPU"
[ $("$CWD"/endiancheck.sh) = "big" ] && endian="BIGENDIAN_CPU"
echo "#define $endian" > tmp.h 

r800_hdr="src/amd/addrlib/inc/chip/r800/si_gb_reg.h"
cat $r800_hdr >> tmp.h
mv tmp.h "$r800_hdr" || exit 1

CPPFLAGS="-D_GNU_SOURCE -I $PWD/include/c11" \
./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --libdir=/usr/lib \
  --mandir=/usr/man \
  --docdir=/usr/doc/${PKGNAM}-$VERSION \
  --with-dri-drivers="$DRI_DRIVERS" \
  --with-gallium-drivers="$GALLIUM_DRIVERS" \
  --enable-gallium-llvm=yes \
  --enable-texture-float \
  --enable-dri \
  --enable-glx \
  --enable-gallium-osmesa \
  --disable-nine \
  --enable-llvm \
  --enable-llvm-shared-libs \
  --enable-xa \
  --enable-gbm \
  --enable-vdpau \
  --disable-asm \
  --disable-glx-tls \
  --with-egl-platforms="drm,x11" \
  --enable-gles1 \
  --enable-gles2 || exit

echo true > bin/missing

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
