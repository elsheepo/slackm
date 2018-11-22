#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=samba
VERSION=latest
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-4.9.1

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-4.9.1
chown -R root:root .

./configure \
--prefix=/usr \
--enable-fhs \
--without-systemd \
--quick \
--without-ad-dc \
--without-libarchive \
--without-acl-support \
--without-ldap \
--without-ads -p \
--disable-python \
--disable-cups \
--disable-iprint \
--without-pam \
--sysconfdir=/etc \
--localstatedir=/var \
--mandir=/usr/man || exit

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
