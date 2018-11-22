#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=wireless_tools
VERSION=29
PKG=$TMP/package_$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP_$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP.$VERSION.tar.?z
cd $APP.$VERSION
chown -R root:root .

patch -p1 < $CWD/wireless-tools-Makefile.patch
patch -p1 < $CWD/wireless-tools-headers.patch

make $jobs CFLAGS="-D_GNU_SOURCE -D_BSD_SOURCE" PREFIX=/usr || exit
make PREFIX=/usr install DESTDIR=$PKG 

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
