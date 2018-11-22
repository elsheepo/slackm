#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=utmp
VERSION=20151018
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.xz
cd $APP-$VERSION
chown -R root:root .

make $jobs CC="$CC" CFLAGS="$SLKCFLAGS" || exit
make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc
mkdir -p $PKG/usr/man/man8
cat utmp.1 | gzip -9c > $PKG/usr/man/man8/utmp.1.gz
rm utmp.1
rm -rf $PKG/usr/share
cd $PKG
mkdir -p var/run
ln -s usr/bin/utmp var/run/utmp
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
