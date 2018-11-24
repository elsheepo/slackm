#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=xorg-server
VERSION=1.20.3
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.xz
cd $APP-$VERSION
chown -R root:root .

sed 's@termio.h@termios.h@g' -i 'hw/xfree86/os-support/xf86_OSlib.h' || exit
sleep 2
printf "all:\n\ttrue\ninstall:\n\ttrue\n" > test/Makefile.in || exit
sleep 2

CFLAGS=-D_GNU_SOURCE \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--mandir=/usr/man \
	--with-fontrootdir="$PREFIX/share/fonts/X11" \
	--with-xkb-output="/var/lib/xkb" \
	--with-sha1=libnettle \
	--disable-docs \
	--disable-devel-docs \
	--disable-strict-compilation \
	--disable-dmx

# X needs udev files. >.>
make $jobs || exit
make install DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
