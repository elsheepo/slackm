#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=snownews
VERSION=1.5.12
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

./configure --disable-nls --prefix=/usr 

patch < $CWD/platform_settings.patch
#patch < $CWD/makefile.patch

make $jobs CC="$CC -static $mcf"
make CC="$CC -static $mcf $mldf" LIBS="-lncurses -lcrypto"

mkdir -p $PKG/bin; cp snownews $PKG/bin/
mkdir -p $PKG/bin; cp opml2snow $PKG/bin/
mkdir -p $PKG/usr/man; cp doc/man/snownews.1 $PKG/usr/man/
mkdir -p $PKG/usr/man; cp doc/man/opml2snow.1 $PKG/usr/man/

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
