#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=jam
VERSION=2.5
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

mkdir -p $TMP/$APP-$VERSION
cd $TMP/$APP-$VERSION
unzip $CWD/$APP-$VERSION
chown -R root:root .

make $jobs || exit
./jam0 -sBINDIR=$PKG/usr/bin install

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
