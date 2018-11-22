#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=rpcbind
VERSION=1.2.5
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2
cd $APP-$VERSION
chown -R root:root .

#patch -p1 < $CWD/CVE-2017-8779.patch
#patch -p1 < $CWD/pmapproc_dump-Fixed-typo-in-memory-leak-patch.patch
patch -p1 < $CWD/rpcbproc_callit_com-Stop-freeing-a-static-pointer.patch

./configure \
--prefix=/usr \
--with-statedir=/var/lib/rpcbind \
--with-rpcuser=rpc \
--enable-warmstarts \
--without-systemdsystemunitdir || exit

make || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
