#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=iputils
VERSION=s20101006
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/001-iputils.patch || exit
patch -p1 < $CWD/002-fix-ipv6.patch || exit
patch -p1 < $CWD/003-fix-makefile.patch || exit
patch -p1 < $CWD/010-ping6_uclibc_resolv.patch || exit
patch -p1 < $CWD/011-ping6_use_gnu_source.patch || exit
patch -p1 < $CWD/020-include_fixes.patch || exit

sleep 0.5

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
