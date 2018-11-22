#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=smstools3
VERSION=3.1.21
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z || exit
cd $APP
chown -R root:root .

CC="gcc -O3 -static" make $jobs || exit

mkdir -p $PKG/bin; cp src/smsd $PKG/bin/
mkdir -p $PKG/install

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
