#!/bin/sh

# README WAY DOWN! 

. /etc/compiler.vars

PKGNAM=mutt
VERSION=1.5.22
BUILD=${BUILD:-1}

TMP=${TMP:-/tmp}
CWD=`pwd` 

PKG=$TMP/package-mutt
rm -rf $PKG
mkdir $PKG
cd $TMP
rm -rf mutt-$VERSION
tar xvf $CWD/mutt-$VERSION.tar.?z* || exit 1
cd mutt-$VERSION || exit 1
chown -R root:root .


# Ok, so to cross compile this software, I had to disable the entire doc directory.
# It so seems that the doc directory contains an executable "makedoc" which is 
# compiled for the host arch instead of the native arch (pretty shamelessly) and 
# is then run. So to prevent that, I simply disabled the doc directory in the 
# Makefile. (References basically). N.B. Makefile in the top level directory. 
#

# I created two patches to remove the doc references from the Makefile.* files.
# The following two commands apply them. :)

patch -p0 < $CWD/Makefile.am.patch
patch -p0 < $CWD/Makefile.in.patch

CC="$CC -static $mcf $mldf" \
CFLAGS="$mcf" \
./configure \
  --prefix=/usr \
  --mandir=/usr/man \
  --docdir=/usr/doc/mutt-$VERSION \
  --with-docdir=/usr/doc/mutt-$VERSION \
  --sysconfdir=/etc/mutt \
  --with-mailpath=/var/spool/mail \
  --enable-smtp \
  --enable-imap \
  --enable-pop \
  --enable-iconv \
  --disable-nls \
  --disable-pgp \
  --enable-debug \
  --disable-gpgme \
  --without-docdir \
  --enable-smime 

# Ok, so to cross compile this software, I had to disable the entire doc directory.
# It so seems that the doc directory contains an executable "makedoc" which is 
# compiled for the host arch instead of the native arch (pretty shamelessly) and 
# is then run. So to prevent that, I simply disabled the doc directory in the 
# Makefile. (References basically). N.B. Makefile in the top level directory. 
# 

make $jobs CC="$CC -static $mcf $mldf" || exit
make install DESTDIR=$PKG || exit 1

# This stuff is redundant or not useful to most people, IMHO.
# If you want it, use the source, Luke.
rm -f $PKG/etc/mutt/*.dist

strdoc
/sbin/makepkg -l y -c n ../mutt-$VERSION-$ARCH-$BUILD.txz
