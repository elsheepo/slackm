#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=fltk
VERSION=1.3.4-2
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION-source.tar.?z
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--mandir=/usr/man \
--enable-shared \
--enable-gl \
--enable-largefile \
--enable-threads \
--enable-xinerama \
--enable-xft \
--enable-xdbe

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
