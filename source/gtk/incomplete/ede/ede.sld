#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=ede
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
--sysconfdir=/etc \
--localstatedir=/var \
--mandir=/usr/man \
--enable-profile=yes \
--enable-hal=no \
--enable-largefile=yes

jam 
mkdir -p $PKG/usr/doc/$PRGNAM-$VERSION
jam -sDESTDIR=$PKG -sEDE_DOC_DIR=/usr/doc/${PRGNAM}-${VERSION} install 

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
