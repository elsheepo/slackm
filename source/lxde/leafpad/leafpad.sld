#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=leafpad
VERSION=0.8.18
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/leafpad-savebug.patch || exit 1
patch -p1 < $CWD/leafpad-taskbar-icon.patch || exit 1

./configure \
--prefix=/usr \
--libdir=/usr\lib \
--mandir=/usr/man \
--disable-nls 

for i in po ; do
        printf 'all:\n\ttrue\ninstall:\n\ttrue\nclean:\n\ttrue\n' > "$i"/Makefile
done

chmod +x install-sh

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
