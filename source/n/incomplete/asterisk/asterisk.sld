#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

# Depends on util-linux's uuid library, jansson library and sqlite3 library

BUILD=1
APP=asterisk
VERSION=13.9.1
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/001-disable-semaphores-check.patch
patch -p1 < $CWD/002-undef-res-ninit.patch
patch -p1 < $CWD/003-disable-ast-xml-docs.patch
patch -p1 < $CWD/004-ifdef-missing-execinfo.patch
patch -p1 < $CWD/030-GNU-GLOB-exts-only-on-glibc.patch
patch -p1 < $CWD/040-fix-config-options.patch
patch -p1 < $CWD/050-musl-glob-compat.patch
patch -p1 < $CWD/051-musl-includes.patch
patch -p1 < $CWD/052-musl-libcap.patch
patch -p1 < $CWD/053-musl-mutex-init.patch

sleep 1 

cd menuselect

./configure \
	--without-newt \
	--without-curses 

make -j2

cd ..

CC="$CC $mcf $mldf" \
CFLAGS="$mcf" \
LDFLAGS="$mldf" \
./configure \
--prefix=/usr \
--disable-xmldoc \
--without-gtk2 \
--without-execinfo \
--without-cap \
--without-curses \
--with-gsm=internal \
--without-isdnnet \
--without-misdn \
--without-nbs \
--without-neon \
--without-neon29 \
--without-netsnmp \
--without-newt \
--without-ogg \
--without-osptk \
--without-pwlib \
--without-radius \
--without-spandsp \
--without-sdl \
--without-suppserv \
--without-tds \
--without-termcap \
--without-tinfo \
--without-vorbis \
--without-vpb \
--disable-asteriskssl \
--without-gmime \
--without-gobject \
--with-bluetooth \
$HOSTDIST || exit

# We need to select the chan_mobile option.
make menuconfig

# This one is hardcoded for now..
make -j2 CFLAGS="-I/home/rico/ch-arm/usr/include -I/home/rico/ch-arm/include $mcf" LDFLAGS="-L/home/rico/ch-arm/usr/lib -L/home/rico/ch-arm/lib $mldf -lxml2"

make install DESTDIR=$PKG all samples 

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
