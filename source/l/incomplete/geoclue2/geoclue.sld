#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=geoclue
VERSION=2.4.7
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

CFLAGS="$mcf" \
CXXFLAGS="$mcf" \
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man \
--sysconfdir=/etc \
--localstatedir=/var \
--disable-nls \
--disable-gtk-doc \
--disable-gtk-doc-html \
--disable-gtk-doc-pdf \
--disable-3g-source \
--disable-cdma-source \
--disable-modem-gps-source \
--disable-nmea-source 

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
