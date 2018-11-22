#!/bin/sh

. /etc/compiler.vars

# requires xf86vm among others

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=freeglut
VERSION=3.0.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

mkdir -p build
cd build
  cmake \
    -DCMAKE_C_FLAGS:STRING="$SLKCFLAGS" \
    -DCMAKE_C_FLAGS_RELEASE:STRING="$SLKCFLAGS" \
    -DCMAKE_CXX_FLAGS:STRING="$SLKCFLAGS" \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="$SLKCFLAGS" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DFREEGLUT_BUILD_DEMOS=ON \
    -DCMAKE_INSTALL_LIBDIR=/usr/lib \
    -DFREEGLUT_BUILD_SHARED_LIBS=ON \
    -DFREEGLUT_BUILD_STATIC_LIBS=OFF \
    -DMAN_INSTALL_DIR=/usr/man \
    -DLIB_SUFFIX=${LIBDIRSUFFIX} \
    .. || exit 1

make $jobs || exit 1
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
