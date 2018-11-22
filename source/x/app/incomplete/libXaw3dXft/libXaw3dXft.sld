#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=libXaw3dXft
VERSION=1.6.2d
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

CC="$CC" \
./configure \
--prefix=/usr 

make $jobs CC="$CC" CFLAGS="$mcf" LDFLAGS="$mldf -lXmu -lXt -lX11 -lXext -lXft" || exit
make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi

# Strip binaries
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
