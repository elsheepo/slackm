#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=iftop
VERSION=0.17
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz 
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--sbindir=/usr/bin \
--mandir=/usr/man

make $jobs 
make install DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
