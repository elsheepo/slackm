#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=bash
VERSION=4.4.12
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

bash_cv_getenv_redef=no \
bash_cv_sys_named_pipes=yes \
./configure \
--prefix=/usr \
--mandir=/usr/man \
--infodir=/usr/info \
--without-bash-malloc \
--disable-rpath \
--enable-history \
--disable-nls 

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
