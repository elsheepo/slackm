#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=rtorrent
VERSION=0.9.6
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

LDFLAGS="-lpthread" \
CFLAGS="$mcf" \
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--sysconfdir=/etc \
--localstatedir=/var \
--mandir=/usr/man 

make $jobs CXX="$CXX -lpthread" || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
