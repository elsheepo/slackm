#!/bin/sh

. /etc/compiler.vars

PKGNAM=llvm
VERSION=${VERSION:-$(echo llvm-*.tar.xz | rev | cut -f 4- -d . | cut -f 1 -d - | rev)}
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-$PKGNAM

rm -rf $PKG
mkdir -p $TMP $PKG
cd $TMP
rm -rf $PKGNAM-${VERSION}.src $PKGNAM-${VERSION}
tar xvf $CWD/$PKGNAM-$VERSION.src.tar.xz || exit 1

cd $PKGNAM-${VERSION}/tools || cd $PKGNAM-${VERSION}.src/tools || exit 1
  tar xvf $CWD/cfe-$VERSION.src.tar.xz || exit 1
  mv cfe-${VERSION} clang 2>/dev/null || mv cfe-${VERSION}.src clang || exit 1
cd ../

cd projects || exit 1
  tar xvf $CWD/compiler-rt-$VERSION.src.tar.xz || exit 1
  mv compiler-rt-${VERSION} compiler-rt 2>/dev/null \
    || mv compiler-rt-${VERSION}.src compiler-rt || exit 1
cd ../

chown -R root:root .

patch -p1 < "$CWD"/llvm36.patch || exit 1
patch -p1 < "$CWD"/llvm36-dynlinker.patch || exit 1

./configure \
--prefix=/usr \
--enable-libffi \
--enable-optimized \
--enable-shared \
--enable-targets=all \
--disable-docs || exit

make $jobs
make install DESTDIR="$PKG" 

# Move man page directory:
mv $PKG/usr/share/man $PKG/usr/

strdoc
/sbin/makepkg -l y -c n $TMP/$PKGNAM-$VERSION-$ARCH-$BUILD.txz

