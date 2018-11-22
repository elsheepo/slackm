#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=libXxf86vm
VERSION=1.1.4
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

ac_cv_func__XEatDataWords=yes \
./configure \
--prefix=/usr \
--mandir=/usr/man

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
