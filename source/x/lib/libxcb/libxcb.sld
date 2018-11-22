#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=libxcb
VERSION=1.13.1
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

CC="$CC $mcf $mldf" \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--mandir=/usr/man \
	--enable-shared \
	--enable-static \
	--enable-xkb \
	--enable-xinput

make $jobs 
make install DESTDIR=$PKG || exit

rm -rf $PKG/usr/man
strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
