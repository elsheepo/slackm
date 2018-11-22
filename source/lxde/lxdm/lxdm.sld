#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=lxdm
VERSION=0.5.3
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/lxdm-backtrace.patch || exit

./configure \
--prefix=/usr \
--libdir=/usr/lib \
--sbindir=/usr/sbin \
--without-pam

for i in po ; do
printf 'all:\n\ttrue\ninstall:\n\ttrue\nclean:\n\ttrue\n' > "$i"/Makefile
done

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
