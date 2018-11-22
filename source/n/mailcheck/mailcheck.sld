#!/bin/sh

. /etc/compiler.vars

PRGNAM=mailcheck
VERSION=1.91.2
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}


echo $PRGNAM
echo $VERSION
rm -rf $PKG
mkdir -p $TMP $PKG $OUTPUT
cd $TMP
rm -rf $PRGNAM-$VERSION

tar -xvf $CWD/mailcheck_1.91.2.tar.gz
cd $PRGNAM-$VERSION
chown -R root:root .

make CC="$CC -static $mcf" 
#make install DESTDIR=$PKG

mkdir -p $PKG/usr/bin
cp mailcheck $PKG/usr/bin/
mkdir -p $PKG/etc
cp mailcheckrc $PKG/etc/

strdoc
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD.txz
