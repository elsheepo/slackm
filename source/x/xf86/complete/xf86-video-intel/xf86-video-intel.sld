#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=xf86-video-intel
VERSION=2.99.917
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2 || exit
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/git.patch

autoreconf -vif

./configure \
--prefix=/usr \
--enable-xvmc \
--disable-dga \
--with-default-dri=3 \
--disable-selective-werror || exit

make $jobs CC="$CC" CFLAGS="$mcf" || exit
make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi

# Strip binaries
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
