#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=edelib
VERSION=2.1
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man \
--localstatedir=/var \
--enable-profile \
--enable-shared \
--enable-largefile || exit

jam
mkdir -p $PKG/usr/lib${LIBDIRSUFFIX}
jam -sDESTDIR=$PKG -slibdir=$PKG/usr/lib${LIBDIRSUFFIX} \
    -sdocdir=$PKG/usr/doc install

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
