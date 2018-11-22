#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=shadow
VERSION=4.2
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

CC="$CC -static" \
CFLAGS="$SLKCFLAGS" \
	./configure \
	--enable-static=yes \
	--enable-shared=no \
	--disable-nls

make CC="$CC -static" LDFLAGS=-all-static 
make install DESTDIR=$PKG || exit

# Command fails to run for unknown reason, reverting to busybox's passwd
# Which is more reliable for now.
rm $PKG/usr/bin/passwd
# Also rm /bin/login since we use ubase's login.
rm $PKG/bin/login
strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
