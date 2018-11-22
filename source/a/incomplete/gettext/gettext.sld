#!/bin/sh

. /etc/compiler.vars

VERSION=0.18.2.1
BUILD=${BUILD:-2}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-gettext

rm -rf $PKG
mkdir -p $TMP $PKG
cd $TMP
rm -rf gettext-$VERSION
tar xvf $CWD/gettext-$VERSION.tar.xz || exit 1
cd gettext-$VERSION
chown -R root:root .

cd gettext-runtime
CC="$CC" \
CFLAGS="$mcf" \
CXXFLAGS="$mcf" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --infodir=/usr/info \
  --mandir=/usr/man \
  --docdir=/usr/doc/gettext-$VERSION \
  --enable-static \
  --enable-shared \
  $HOSTDIST

make $jobs 
make install DESTDIR=$PKG

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/gettext-$VERSION-$ARCH-$BUILD.txz

