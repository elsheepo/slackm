#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=ruby
VERSION=2.2.5
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

CFLAGS="$mcf" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --mandir=/usr/man \
  --datadir=/usr/share \
  --docdir=/usr/doc/ruby-$VERSION \
  --enable-shared \
  --enable-pthread \
  --disable-install-capi 

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
