#!/bin/sh

. /etc/compiler.vars

VERSION=1.4.20
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-iptables

rm -rf $PKG
mkdir -p $TMP $PKG
cd $TMP
rm -rf iptables-$VERSION
tar xvf $CWD/iptables-$VERSION.tar.?z* || exit 1
cd iptables-$VERSION || exit 1

chown -R root:root .

patch -p1 < $CWD/iptables-1.4.14-musl-fixes.patch
sleep 2

CC="$CC $mcf $mldf" \
CFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --mandir=/usr/man \
  --docdir=/usr/doc/iptables-$VERSION \
  --enable-static 

make $jobs CC="$CC $mcf $mldf" CFLAGS="$SLKCFLAGS" LDFLAGS=-all-static
make install DESTDIR=$PKG || exit 1

strdoc
/sbin/makepkg -l y -c n $TMP/iptables-$VERSION-$ARCH-$BUILD.txz
