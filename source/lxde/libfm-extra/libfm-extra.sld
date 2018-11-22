#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=libfm-extra
VERSION=1.2.4
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/libfm-$VERSION.tar.?z
cd libfm-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--sysconfdir=/etc \
--with-extra-only \
--disable-static \
--with-gtk=no

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
