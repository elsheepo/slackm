#!/bin/sh

. /etc/compiler.vars

PRGNAM=warzone2100
VERSION=${VERSION:-3.2.3}
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp/SBo}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

rm -rf $PKG $TMP/$PRGNAM-$VERSION
mkdir -p $TMP $PKG $OUTPUT
cd $TMP
tar xvf $CWD/$PRGNAM-$VERSION.tar.?z
cd $PRGNAM-$VERSION
chown -R root:root .

LIBS="-lexecinfo" \
CFLAGS="$SLKCFLAGS" \
CXXFLAGS="$SLKCFLAGS -fpermissive" \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib${LIBDIRSUFFIX} \
  --mandir=/usr/man \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --docdir=/usr/doc/$PRGNAM-$VERSION \
  --with-distributor=Slackware || exit 1

make $jobs || exit 1
make install-strip DESTDIR=$PKG || exit 1

find $PKG/usr/man -type f -exec gzip -9 {} \;
for i in $( find $PKG/usr/man -type l ) ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done

find $PKG -name perllocal.pod \
  -o -name ".packlist" \
  -o -name "*.bs" \
  | xargs rm -f

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc
cat $CWD/doinst.sh > $PKG/install/doinst.sh

strdoc
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD.txz
