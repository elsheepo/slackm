#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=pixman
VERSION=0.34.0
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

# Depends on zlib and libpng

CC="$CC $mcf $mldf" \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--mandir=/usr/man \
	--disable-arm-simd \
	--disable-arm-neon \
	--disable-arm-iwmmxt \
	--disable-arm-iwmmxt2 \
	--disable-gcc-inline-asm \
	--disable-timers 

make -j2 
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz
