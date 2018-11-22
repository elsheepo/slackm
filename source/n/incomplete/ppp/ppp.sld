#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=ppp
VERSION=2.4.7
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

./configure 

patch -p0 < $CWD/01-makefile.patch
patch -p1 < $CWD/130-no_cdefs_h.patch
patch -p1 < $CWD/132-fix_linux_includes.patch
patch -p1 < $CWD/133-fix_sha1_include.patch
patch -p1 < $CWD/403-no_wtmp.patch

make $jobs CC="$CC $mcf" CFLAGS="$mldf" LDFLAGS="$mldf -lpcap" -C pppd

mkdir -p $PKG/usr/sbin
cp pppd/pppd $PKG/usr/sbin/

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -f $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi
cd $PKG
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
