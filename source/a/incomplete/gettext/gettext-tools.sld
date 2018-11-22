#!/bin/sh

. /etc/compiler.vars

VERSION=0.18.2.1
BUILD=${BUILD:-2}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-gettext-tools

rm -rf $PKG
mkdir -p $TMP $PKG
cd $TMP
rm -rf gettext-$VERSION
tar xvf $CWD/gettext-$VERSION.tar.xz || exit 1
cd gettext-$VERSION
chown -R root:root .

CC="$CC" \
CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --infodir=/usr/info \
  --mandir=/usr/man \
  --docdir=/usr/doc/gettext-tools-$VERSION \
  --enable-static \
  --enable-shared \
  $HOSTDIST

make $jobs 

cd gettext-tools
make install DESTDIR=$PKG

mkdir -p $PKG/install
cat $CWD/slack-desc.gettext-tools > $PKG/install/slack-desc

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/gettext-tools-$VERSION-$ARCH-$BUILD.txz

