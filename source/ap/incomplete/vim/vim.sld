#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=vim
VERSION=7.4
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

CC="$CC $mcf $mldf" \
CFLAGS="$SLKCFLAGS" \
	./configure \
	--prefix=/usr \
	--disable-gpm \
	--disable-gtktest \
	--disable-gui \
	--disable-netbeans \
	--disable-nls \
	--disable-selinux \
	--disable-sysmouse \
	--disable-xsmp \
	--without-x \
	--with-tlib=ncurses \
	$HOSTDIST


make $jobs CC="$CC $mcf $mldf" CFLAGS="$SLKCFLAGS" 
make install DESTDIR=$PKG || exit

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc
cd $PKG
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH.txz 
