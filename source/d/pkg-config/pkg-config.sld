#!/bin/sh

. /etc/compiler.vars

PKGNAM=pkg-config
VERSION=0.29.2
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-pkg-config
rm -rf $PKG
mkdir -p $TMP $PKG/usr

cd $TMP
rm -rf pkg-config-$VERSION
tar xvf $CWD/pkg-config-$VERSION.tar.?z* || exit 1
cd pkg-config-$VERSION || exit 1
chown -R root:root .

CC="$CC -static" \
CFLAGS="$SLKCFLAGS" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --mandir=/usr/man \
  --docdir=/usr/doc/pkg-config-$VERSION \
  --with-internal-glib

make $jobs LDFLAGS=-all-static 
make install DESTDIR=$PKG || exit 1

mkdir -p $PKG/etc/profile.d/
for script in $(ls $CWD/scripts/*) ; do
  cat ${script} | sed -e "s#/lib/#/lib${LIBDIRSUFFIX}/#g" \
    > $PKG/etc/profile.d/$(basename ${script})
done
chown root:root $PKG/etc/profile.d/*
chmod 755 $PKG/etc/profile.d/*

mkdir -p $PKG/install
#zcat $CWD/doinst.sh.gz | sed -e "s#/lib/#/lib${LIBDIRSUFFIX}/#g" \
#  > $PKG/install/doinst.sh
cat $CWD/slack-desc > $PKG/install/slack-desc

cd $TMP/package-pkg-config; str
/sbin/makepkg -l y -c n $TMP/pkg-config-$VERSION-$ARCH-$BUILD.txz
