#!/bin/sh
# depends on openssl, glproto and X proto friends
. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=mesa
VERSION=13.0.6
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--sysconfdir=/etc \
--libdir=/usr/lib \
--enable-gallium-tests=no \
--enable-texture-float \
--disable-gallium-llvm \
--with-gallium-drivers="" \
--enable-gles1 \
--enable-gles2 \
--enable-osmesa \
--enable-gbm \
--enable-xa \
--enable-egl \
--with-egl-platforms="drm,x11" || exit

make $jobs
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
