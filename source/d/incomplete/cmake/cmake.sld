#!/bin/sh

# Need to edit shit in /tmp/cmake-$VERSION/SourceFiles/CMakeFiles/
# {ccache.dir/cmake.dir}/link.txt,flags.make

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=cmake
VERSION=3.5.2
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

CXX_INCLUDES="$mcf" \
CXX="$CXX -static $mcf $mldf" \
CFLAGS="$mcf -static" \
CPPFLAGS="$mcf -static" \
./bootstrap \
--prefix=/usr \
--no-system-curl \
--no-system-expat \
--no-system-jsoncpp \
--no-system-zlib \
--no-system-bzip2 \
--no-system-libarchive || exit

CXX_INCLUDES="$mcf" \
CXX="$CXX -static $mcf" \
CFLAGS="$mcf -static" \
CPPFLAGS="$mcf -static" \
./configure \
--prefix=/usr \
--no-system-curl \
--no-system-expat \
--no-system-jsoncpp \
--no-system-zlib \
--no-system-bzip2 \
--no-system-libarchive || exit

CXX_INCLUDES="$mcf" CFLAGS="$mcf -static" CPPFLAGS="$mldf -static" make $jobs CC="$CC -static $mcf $mldf" CXX="$CXX -static$mcf $mldf" CFLAGS="$mcf -static" CPPFLAGS="$mcf -static" || exit
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
