#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=autoconf
VERSION=2.13
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $TMP/$APP-$VERSION
chown -R root:root .

echo $PWD
./configure \
--prefix=/usr

make $jobs || exit

mkdir -p $PKG/usr/bin
cp autoconf $PKG/usr/bin/autoconf213
cp autoheader $PKG/usr/bin/autoheader213
cp autoreconf $PKG/usr/bin/autoreconf213
cp autoscan $PKG/usr/bin/autoscan213
cp autoupdate $PKG/usr/bin/autoupdate213
strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
