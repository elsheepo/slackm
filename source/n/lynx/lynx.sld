#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=lynx
VERSION=2.8.8rel.2
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP
rm -rf $TMP/lynx2-8-8
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP$VERSION.tar.?z
cd lynx2-8-8
chown -R root:root .

LIBS="-lncurses -lterminfo" \
CFLAGS="$mcf" \
./configure \
--prefix="" \
--mandir=/usr/man \
--with-ssl 

make $jobs  
make install DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
