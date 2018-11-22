#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=fail2ban
VERSION=0.9.4
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

python setup.py install --root="$PKG"
mkdir -p $PKG/etc/rc.d
cp $CWD/rc.fail2ban $PKG/etc/rc.d/

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
