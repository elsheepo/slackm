#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=mupdf
VERSION=1.12.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION-source

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION-source.tar.?z
cd $APP-$VERSION-source
chown -R root:root .

rm -rf thirdparty/curl thirdparty/freetype thirdparty/jpeg thirdparty/zlib thirdparty/jbig2dec
PCS_SAVE="$PKG_CONFIG_SYSROOT_DIR"
PCL_SAVE="$PKG_CONFIG_LIBDIR"
PKG_CONFIG_SYSROOT_DIR=
PKG_CONFIG_LIBDIR=
# fontdump bin2hex cquote namedump
for i in cmapdump hexdump; do
        make verbose=yes CC=cc \
        FREETYPE_CFLAGS=-I/usr/include/freetype2 \
        FREETYPE_LIBS=-lfreetype \
        OPENSSL_CFLAGS="-DHAVE_OPENSSL" \
        OPENSSL_LIBS="-lssl -lcrypto" \
        build=release build/release/scripts/"$i".exe
done

PKG_CONFIG_SYSROOT_DIR="$PCS_SAVE"
PKG_CONFIG_LIBDIR="$PCL_SAVE"

make verbose=yes -j $MAKE_THREADS DESTDIR="$PKG" \
HAVE_GLFW=no HAVE_GLUT=no \
prefix="/usr" build=release install

# Fix permissions
find $PKG -type f | xargs chmod 644
chmod 755 $PKG/usr/bin/*

# .desktop taken from debian and modified:
mkdir -p $PKG/usr/share/applications
cat $CWD/$APP.desktop > $PKG/usr/share/applications/$APP.desktop

# Icon converted from platform/x11/mupdf.ico, with icotool
mkdir -p $PKG/usr/share/pixmaps
cat $CWD/$APP.png > $PKG/usr/share/pixmaps/$APP.png

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
