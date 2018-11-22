#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=shared-mime-info
VERSION=1.7
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

mkdir .deps
touch .deps/update_mime_database-update-mime-database.Tpo

./configure \
--prefix=/usr \
--mandir=/usr/man \
--disable-nls \
--libdir=/usr/lib

sed -i 's@$(AM_V_at)$(am__mv) $(DEPDIR)/update_mime_database-update-mime-database.Tpo@#@' Makefile

for i in po ; do
        printf 'check:\n\ttrue\n\nall:\n\ttrue\ninstall:\n\ttrue\nclean:\n\ttrue\n\n' > "$i"/Makefile
done

make -j1 V=1 || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
