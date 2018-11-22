#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

# Requires libnl, which again requires flex. 

BUILD=2
APP=kismet
VERSION=2016-01-R1
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.xz
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/010-dont-add-host-include-paths.patch
patch -p1 < $CWD/020-musl-include-fixes.patch
patch -p1 < $CWD/030-ncurses.patch

sleep 1 

ac_cv_lib_panel_new_panel=yes \
./configure \
--prefix=/usr \
--disable-pcre 

#patch -p1 < $CWD/040-makefile.patch || exit
sleep 1

make $jobs
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
