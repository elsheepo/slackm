#!/bin/sh

. /etc/compiler.vars

# requires xcb-util

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=xcb-util-image
VERSION=0.4.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
