#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=dovecot
VERSION=2.2.21
PKG=$TMP/package-$APP

rm -rf $PKG
rm -rf $TMP/$APP-$VERSION
mkdir -p $TMP $PKG

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz 
cd $APP-$VERSION
chown -R root:root .

i_cv_epoll_works=yes \
i_cv_posix_fallocate_works=yes \
i_cv_signed_size_t=no \
i_cv_gmtime_max_time_t=32 \
i_cv_signed_time_t=yes \
i_cv_mmap_plays_with_write=yes \
i_cv_fd_passing=yes \
i_cv_c99_vsnprintf=yes \
lib_cv_va_copy=yes \
lib_cv___va_copy=yes \
lib_cv_va_val_copy=yes \
CC="$CC -static" \
./configure \
--sysconfdir=/etc \
--prefix=/usr \
--localstatedir=/var \
--without-nss \
--without-shadow \
--without-bsdauth \
--without-pam \
--without-ssl \
--without-icu \
--without-stemmer \
--without-textcat \
--without-bzlib \
--without-lzma \
--without-lz4 \
--without-libpcap \
--without-libwrap \
--without-docs \
--without-gssapi \
--without-mysql \
--enable-static \
--disable-shared \
$HOSTDIST

make $jobs CC="$CC $mcf $mldf" CFLAGS="$SLKCFLAGS" LDFLAGS=-all-static
make install DESTDIR=$PKG || exit

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
