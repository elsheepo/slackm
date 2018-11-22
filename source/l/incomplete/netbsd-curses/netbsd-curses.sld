#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=netbsd-curses
VERSION=0.2.2
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

cat << EOF > config.mak
CC="$CC" 
MANDIR="/usr/man"
PREFIX="/usr"
DESTDIR="$PKG"
EOF

make $jobs || exit
make terminfo/terminfo.cdb
make install DESTDIR=$PKG

mkdir -p $PKG/usr/share
cp terminfo/terminfo.cdb $PKG/usr/share/
strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
