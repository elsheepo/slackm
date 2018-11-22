#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=4
APP=firefox
VERSION=52.0esr.source
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION
rm -rf $TMP/firefox-52.0esr

cd $TMP || exit
# github doesn't love individual files >=100M, so I've split the files
# and pushed them to github.
# To split,
# split -b 80M -d -a 3 firefox-52.0esr.source.tar.xz firefox-52.0esr.source.tar.xz.00

# In this instance, we are simply remerging the split files into one using the 
# brilliant kitty command!
if [ ! -e $CWD/firefox-52.0esr.source.tar.xz ]; then
cat $CWD/firefox-52.0esr.source.tar.xz.0* > $CWD/firefox-52.0esr.source.tar.xz
fi
tar -xvf $CWD/$APP-$VERSION.tar.?z || exit 1
cd $APP-52.0esr
chown -R root:root .

patch -p1 < $CWD/firefox-disable-hunspell_hooks.patch || exit 1
patch -p1 < $CWD/firefox-disable-moz-stackwalk.patch || exit 1
patch -p1 < $CWD/firefox-finite.patch || exit 1
patch -p1 < $CWD/firefox-fix-arm-atomics-grsec.patch || exit 1
patch -p1 < $CWD/firefox-fix-arm-version-detect.patch || exit 1
patch -p1 < $CWD/firefox-fix-toolkit.patch || exit 1
patch -p1 < $CWD/firefox-fix-tools.patch || exit 1
patch -p1 < $CWD/firefox-getprotobyname_r.patch || exit 1
patch -p1 < $CWD/firefox45-libavutil.patch || exit 1
patch -p1 < $CWD/firefox45-mallinfo.patch || exit 1
patch -p1 < $CWD/firefox45-seccomp-bpf.patch || exit 1

cd build
../configure \
--prefix="/usr" \
--disable-pulseaudio \
--enable-alsa \
--disable-necko-wifi \
--enable-official-branding \
--libdir=/usr/lib \
--enable-application=browser \
--enable-default-toolkit=cairo-gtk2 \
--disable-startup-notification \
--enable-strip \
--enable-cpp-rtti \
--disable-tests \
--disable-printing \
--disable-gio \
--disable-dbus \
--disable-gconf \
--disable-accessibility \
--disable-crashreporter \
--disable-webrtc \
--disable-jemalloc \
--disable-replace-malloc \
--disable-callgrind || exit 1

make $jobs || exit 1
make install DESTDIR=$PKG

# sabotage linux does a cleanup of the headers and the
# /usr/bin/firefox script, replacing it with another script
# that has LD_LIBRARY_PATH set for correct finding of libs
# at runtime. So we follow suit.

mkdir -p "$PKG"/usr/bin
rm -rf "$PKG"/include "$PKG"/lib/firefox-devel-52.0
rm -f "$PKG"/usr/bin/firefox
cp "$CWD"/firefox "$PKG"/usr/bin/
chmod +x "$PKG"/usr/bin/firefox

strdoc
/sbin/makepkg -l y -c n $TMP/firefox-52.0esr-$ARCH-$BUILD.txz 
