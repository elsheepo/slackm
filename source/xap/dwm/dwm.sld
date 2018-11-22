#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=dwm
VERSION=6.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

make CC="$CC $mcf $mldf" LIBS="-lX11 -lXinerama -lxcb -lXau -lXdmcp -lXext"
make install PREFIX=/usr DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
