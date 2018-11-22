#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=glu
VERSION=9.0.0
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
--libdir=/usr/lib \
--sysconfdir=/etc \
--mandir=/usr/man \
--localstatedir=/var

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
