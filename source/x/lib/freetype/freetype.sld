#!/bin/sh

. /etc/compiler.vars

PKGNAM=freetype
VERSION=2.9
BUILD=1

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-freetype

rm -rf $PKG
mkdir -p $TMP $PKG
cd $TMP
rm -rf freetype-$VERSION
tar xvf $CWD/freetype-$VERSION.tar.?z || exit 1
cd freetype-$VERSION

chown -R root:root .
chown -R root:root .

./configure \
             --prefix=/usr \
	     --libdir=/usr/lib \
	     --enable-static \
	     --enable-shared \
	     --mandir=/usr/man \
	     --without-nls 

make $jobs 
make install DESTDIR=$PKG

mkdir $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc

cd $PKG/usr/include; ln -s freetype2 freetype
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/freetype-$VERSION-$ARCH-$BUILD.txz

