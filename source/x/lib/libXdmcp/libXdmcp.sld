#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=libXdmcp
# Depends on xproto :-)
VERSION=1.1.2
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

#export LDFLAGS="-L/home/rico/xl/x/xproto/test/usr/lib"
#export CFLAGS="-I/home/rico/xl/x/xproto/test/usr/include"

export LDFLAGS="$mldf" 
export CFLAGS="$mcf"

	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--mandir=/usr/man 

make $jobs 
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz
