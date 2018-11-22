#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=wine
VERSION=1.8.7
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z2 || exit
cd $APP-$VERSION
chown -R root:root .

./configure \
--prefix=/usr \
--sysconfdir=/etc \
--mandir=/usr/man \
--disable-win16 \
--enable-win64 \
--without-alsa \
--without-capi \
--without-cms \
--without-coreaudio \
--without-curses \
--without-dbus \
--without-fontconfig \
--without-freetype \
--without-gettext \
--without-gphoto \
--without-glu \
--without-gsm \
--without-gstreamer \
--without-hal \
--without-jpeg \
--without-ldap \
--without-mpg123 \
--without-netapi \
--without-openal \
--without-opencl \
--without-opengl \
--without-osmesa \
--without-oss \
--without-pcap \
--without-png \
--without-pthread \
--without-pulse \
--without-sane \
--without-tiff \
--without-v4l \
--without-xcomposite \
--without-xcursor \
--without-xinerama \
--without-xinput \
--without-xinput2 \
--without-xml \
--without-xrandr \
--without-xrender \
--without-xshape \
--without-xshm \
--without-xslt \
--without-xxf86vm \
--with-x || exit

make $jobs || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
