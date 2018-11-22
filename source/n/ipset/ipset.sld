#!/bin/sh

# Requires the kernel source directory: /usr/src/linux-$VERSION
# And the .config file it was built with.
# Also requires libmnl

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=ipset
VERSION=6.38
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--mandir=/usr/man \
--with-included-ltdl \
--with-kmod=yes \
--with-kbuild=/usr/src/linux-4.9 \
--with-ksource=/usr/src/linux-4.9 

make $jobs V=s || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
