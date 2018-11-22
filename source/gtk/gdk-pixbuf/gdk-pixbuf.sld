#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=3
APP=gdk-pixbuf
VERSION=2.33.1
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > tests/Makefile.in
gio_can_sniff=yes \
CFLAGS="-D_GNU_SOURCE" \
LDFLAGS="-lz" 
./configure \
--prefix=/usr \
--mandir=/usr/man \
--disable-introspection \
--disable-nls

make $jobs || exit
make install DESTDIR=$PKG

mkdir -p $PKG/usr/include/gdk-pixbuf-xlib
cp -r contrib/gdk-pixbuf-xlib/*.h $PKG/usr/include/gdk-pixbuf-xlib/

# Install wrappers for the binaries:
cp $CWD/update-gdk-pixbuf-loaders $PKG/usr/bin/update-gdk-pixbuf-loaders
chmod 0755 $PKG/usr/bin/update-gdk-pixbuf-loaders

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
