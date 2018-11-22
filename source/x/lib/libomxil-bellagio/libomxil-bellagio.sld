#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=libomxil-bellagio
VERSION=1.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z || exit
cd $APP-$VERSION
chown -R root:root .

CFLAGS="" \
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man \
--disable-doc \
--disable-components

make $jobs CFLAGS="-O2" || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
