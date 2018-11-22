#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=qemu
VERSION=2.12.1
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/0001-elfload-load-PIE-executables-to-right-address.patch
patch -p1 < $CWD/0001-linux-user-fix-build-with-musl-on-aarch64.patch
patch -p1 < $CWD/0001-linux-user-fix-build-with-musl-on-ppc64le.patch
patch -p1 < $CWD/0001-ui-add-x_keymap.o-to-modules.patch
patch -p1 < $CWD/0006-linux-user-signal.c-define-__SIGRTMIN-MAX-for-non-GN.patch
patch -p1 < $CWD/fix-sigevent-and-sigval_t.patch
patch -p1 < $CWD/fix-sockios-header.patch
patch -p1 < $CWD/ignore-signals-33-and-64-to-allow-golang-emulation.patch
patch -p1 < $CWD/musl-F_SHLCK-and-F_EXLCK.patch
#patch -p1 < $CWD/ncurses.patch
patch -p1 < $CWD/test-crypto-ivgen-skip-essiv.patch
patch -p1 < $CWD/xattr_size_max.patch
sleep 1

LIBS="-lncurses -lterminfo" \
CFLAGS="$mcf" \
./configure --prefix="/usr" \
--disable-strip \
--enable-kvm \
--enable-virtfs \
--disable-werror \
--disable-vnc \
--disable-bluez \
--target-list=x86_64-softmmu,i386-softmmu,arm-softmmu \
--sysconfdir=/etc \
--localstatedir=/var \
--enable-sdl \
--enable-tools \
--enable-libusb \
--enable-vnc \
--enable-vnc-jpeg \
--enable-vnc-png \
--enable-gtk \
$alsalib

make $jobs V=1 || exit
make install DESTDIR=$PKG

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
