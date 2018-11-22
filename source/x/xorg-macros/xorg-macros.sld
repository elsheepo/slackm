#!/bin/sh
CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=xorg-macros
#VERSION=
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP

cd $TMP; tar -xvf $CWD/$APP.tar.?z || exit
cd $APP
autoreconf -vif

./configure \
--prefix=/usr

make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc

cd $PKG
/sbin/makepkg -l y -c n $TMP/$APP-noarch-$BUILD.txz 
