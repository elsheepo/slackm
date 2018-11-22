#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=lxc
VERSION=2.0.5
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--sysconfdir=/etc \
--libdir=/usr/lib \
--localstatedir=/var \
--mandir=/usr/man \
--docdir=/usr/doc/ \
--infodir=/usr/info \
--disable-werror \
--disable-apparmor \
--with-distro=alpine 

make $jobs || exit
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
