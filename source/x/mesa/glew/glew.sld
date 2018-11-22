#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=glew
VERSION=2.1.0
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

# Remove the DOS linefeeds from config.guess
TEMPFILE=$(mktemp)
fromdos < config/config.guess > $TEMPFILE || exit
cat $TEMPFILE > config/config.guess ; rm -f $TEMPFILE

make $NUMJOBS OPT="$SLKCFLAGS" LIBDIR=/usr/lib || make OPT="$SLKCFLAGS" || exit 1
make install.all LIBDIR=/usr/lib libdir=/usr/lib GLEW_DEST=$PKG/usr || exit 1
make $jobs || exit
make install LIBDIR=/usr/lib DESTDIR=$PKG 

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
