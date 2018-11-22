#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=netsurf-all
VERSION=3.8
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .


sed \
  -e 's:_BSD_SOURCE:_DEFAULT_SOURCE:' \
  -e 's:(WARNFLAGS) -Werror:(WARNFLAGS):' \
  -i */Makefile */*/Makefile.target

make install DESTDIR=$PKG PREFIX=/usr 

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
