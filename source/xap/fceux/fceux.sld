#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=fceux
VERSION=2.2.3
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/ioapi.patch
sleep 2

sed -i \
  -e "s|/share/man/man6/|/man/man6/|" \
  -e "s|/share/man/man6/|/man/man6/|" \
  -e "s|symbols', 1|symbols', 0|" \
  -e "s|release', 0|release', 1|" \
  SConstruct

scons install -i --prefix=$PKG/usr || exit

# Delete low res icon and replace below, also delete unneeded .dll files
rm -f $PKG/usr/share/pixmaps/fceux.png
rm -f $PKG/usr/share/$PRGNAM/*.dll

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
