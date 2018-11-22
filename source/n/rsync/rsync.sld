#!/bin/sh

. /etc/compiler.vars

PKGNAM=rsync
VERSION=3.1.2
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-rsync
rm -rf $PKG
mkdir -p $TMP $PKG

cd $TMP
rm -rf rsync-$VERSION
tar xvf $CWD/rsync-$VERSION.tar.?z* || exit 1
cd rsync-$VERSION || exit 1

chown -R root:root .

CC="$CC -static" \
./configure \
  --prefix=/usr \
  --disable-locale \
  $HOSTDIST || exit

make $jobs CC="$CC -static" || exit

mkdir -p $PKG/usr/bin
cat rsync > $PKG/usr/bin/rsync
chmod 755 $PKG/usr/bin/rsync

cat rsyncd.conf.5 | gzip -9c > $PKG/usr/man/man5/rsyncd.conf.5.gz

strdoc
/sbin/makepkg -l y -c n $TMP/rsync-$VERSION-$ARCH-$BUILD.txz
