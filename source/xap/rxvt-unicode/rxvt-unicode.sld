#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=rxvt-unicode
VERSION=9.22
PKG=$TMP/package-$APP
BUILD=4

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.bz2
cd $APP-$VERSION
chown -R root:root .

LIBS="-lncurses -lterminfo" \
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--sysconfdir=/etc \
--mandir=/usr/man \
--enable-everything \
--enable-256-color \
--enable-unicode3 \
--enable-xft \
--enable-font-styles \
--enable-transparency \
--enable-fading \
--enable-frills \
--enable-pixbuf \
--enable-rxvt-scroll \
--enable-next-scroll \
--enable-xterm-scroll \
--enable-xim \
--enable-iso14755 \
--enable-keepscrolling \
--enable-smart-resize \
--enable-text-blink \
--enable-pointer-blank \
--disable-perl \
--disable-wtmp \
--disable-lastlog
	
make $jobs 
mkdir -p $PKG/usr/share/terminfo/r

#make install DESTDIR=$PKG || exit
mkdir -p $PKG/usr/bin
cp src/rxvt $PKG/usr/bin/urxvt
cp src/rxvtd $PKG/usr/bin/urxvtd
cp src/rxvtc $PKG/usr/bin/urxvtc
cp $CWD/rxvt-unicode $PKG/usr/share/terminfo/r/
cp $CWD/rxvt-unicode-256color $PKG/usr/share/terminfo/r/

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz
