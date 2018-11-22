#!/bin/sh

. /etc/compiler.vars

VERSION=1.10
SRCVER=110
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-nc
rm -rf $PKG
mkdir -p $TMP $PKG

cd $TMP
rm -rf nc-$SRCVER
mkdir nc-$SRCVER
cd nc-$SRCVER
tar xvf $CWD/nc${SRCVER}.tgz || exit 1
zcat $CWD/nc-110-21.diff.gz | patch -p1 --verbose || exit 1
zcat $CWD/nc.diff.gz | patch -p1 --verbose || exit 1

chown -R root:root .

make linux CC="$CC -static"  CFLAGS="$SLKCFLAGS" || exit 1

mkdir -p $PKG/usr/bin
cat nc > $PKG/usr/bin/nc
chmod 755 $PKG/usr/bin/nc

mkdir -p $PKG/usr/man/man1
cat debian/nc.1 | gzip -9c > $PKG/usr/man/man1/nc.1.gz

strdoc
/sbin/makepkg -l y -c n $TMP/nc-$VERSION-$ARCH-$BUILD.txz
