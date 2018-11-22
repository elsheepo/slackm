#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=wavemon
VERSION=0.7.6
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--mandir=/usr/man

make $jobs CC="gcc -static"
make install DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
