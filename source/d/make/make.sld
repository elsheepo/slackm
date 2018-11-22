#!/bin/sh

. /etc/compiler.vars

PKGNAM=make
VERSION=3.82
BUILD=1

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-make

rm -rf $PKG
mkdir -p $TMP $PKG

cd $TMP
rm -rf make-$VERSION
tar xvf $CWD/make-$VERSION.tar.?z || exit 1
cd make-$VERSION || exit 1
chown -R root:root .

CC="$CC -static" \
CFLAGS="$SLKCFLAGS" \
./configure \
--prefix=/usr \


make $jobs CC="$CC -static" LDFLAGS=-static
make install DESTDIR=$PKG || exit 1

( cd $PKG/usr/bin
  rm -f gmake
  ln -sf make gmake )

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc

# Build the package:
echo $PKG
cd $PKG; str
makepkg -l y -c n $TMP/make-$VERSION-$ARCH-$BUILD.txz

