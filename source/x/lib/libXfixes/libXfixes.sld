#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=libXfixes
VERSION=5.0.3
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

CC="gcc $mcf $mldf -DHAVE__XEATDATAWORDS=1" \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--mandir=/usr/man 

make $jobs 
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
