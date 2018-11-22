#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=distcc
VERSION=3.3
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

# Make sure we change code/docs to use lib64 if needed:
if [ ! "$LIBDIRSUFFIX" = "" ]; then
  grep -l -r usr/lib/distcc | while read file ; do
    sed -i "s|usr/lib/distcc|usr/lib/distcc|g" $file
  done
fi
sed -i "s|usr/lib/gcc|usr/lib/gcc|g" update-distcc-symlinks.py

./configure \
--prefix=/usr \
--datadir=/usr/share \
--sysconfdir=/etc \
--mandir=/usr/man \
--with-gtk \
--without-gnome \
--without-avahi \
--disable-Werror || exit 1 

make $jobs || exit
make install DESTDIR=$PKG

# Make a masquarade directory in /usr/lib:
GCCVER=$(gcc -dumpversion)
mkdir -p $PKG/usr/lib/distcc
( cd $PKG/usr/lib/distcc 
  ln -sf ../../bin/distcc c++
  ln -sf ../../bin/distcc c89
  ln -sf ../../bin/distcc c99
  ln -sf ../../bin/distcc cc
  ln -sf ../../bin/distcc clang
  ln -sf ../../bin/distcc clang++
  ln -sf ../../bin/distcc g++
  ln -sf ../../bin/distcc gcc
  ln -sf ../../bin/distcc gcc-$GCCVER
)

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
