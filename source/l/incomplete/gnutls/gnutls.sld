#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=gnutls
VERSION=3.4.7
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

# Depends on nettle and gmp libraries

CC="$CC $mcf $mdlf" \
NETTLE_CFLAGS="$mcf" \
NETTLE_LIBS="$mldf" \
HOGWEED_CFLAGS="$mcf" \
HOGWEED_LIBS="$mldf" \
NETTLE_CFLAGS="$mcf" \
NETTLE_LIBS="$mldf" \
CFLAGS="$mcf" \
LDFLAGS="$mldf -lgmp" \
	./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--mandir=/usr/man \
	--enable-static \
	--enable-shared \
	--with-included-libtasn1 \
	$HOSTDIST || exit

make $jobs CFLAGS="$mcf" || exit
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH.txz
