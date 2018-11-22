#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=x2x
VERSION=1.32
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .


CC="$CC -static $mcf $mldf" \
CFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  $HOSTDIST

make CC="$CC -static $mcf $mldf" CFLAGS="$SLKCFLAGS" LIBS="-lX11 -lxcb -lXau -lXext -lXtst" || exit
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
