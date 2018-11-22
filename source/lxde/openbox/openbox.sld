#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=openbox
VERSION=3.5.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/openbox-git.patch
sleep 0.5

./configure \
--prefix=/usr \
--mandir=/usr/man \
--sysconfdir=/etc \
--disable-nls \
--disable-imlib2 
#--disable-startup-notification

echo true > missing

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
