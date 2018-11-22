#!/bin/sh

. /etc/compiler.vars

PRGNAM=cgit
VERSION=${VERSION:-1.2.1}
BUILD=${BUILD:-1}
TAG=${TAG:-_SBo}

DOCROOT=${DOCROOT:-/var/www}

CWD=$(pwd)
TMP=${TMP:-/tmp/SBo}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

CGIT_VERSION=${CGIT_VERSION:-v$VERSION}
GIT_VERSION=${GIT_VERSION:-2.15.1}

DOCS="cgitrc.5.txt COPYING README $CWD/config/cgitrc.sample \
      $CWD/config/cgit-lighttpd.conf $CWD/config/cgit-httpd.conf \
      $CWD/config/email-libravatar-korg-additions.css \
      $CWD/config/email-gravatar-sbo-additions.css"

rm -rf $PKG
mkdir -p $TMP $PKG $OUTPUT
cd $TMP
rm -rf $PRGNAM-$VERSION
tar xvf $CWD/v$VERSION.tar.gz || tar xvf $CWD/$PRGNAM-$VERSION.tar.?z*
cd $PRGNAM-$VERSION
chown -R root:root .

# prepare sources
sed -i Makefile \
    -e "s|-g -Wall -Igit|-Wall ${SLKCFLAGS} -Igit|" \
    -e "s|\/lib$|/lib${LIBDIRSUFFIX}|" \
    -e "s|(libdir)|(prefix)/share|" \
    -e "s|/usr/local|/usr|" || exit 1
sed -e "s|@DOCROOT@|$DOCROOT|g" $CWD/config/cgit.conf > cgit.conf
echo "CGIT_VERSION = $CGIT_VERSION" >> cgit.conf

# extract the git tarball
rm -fR git
tar xvf $CWD/git-$GIT_VERSION.tar.?z*
mv git-* git

make \
  prefix="/usr" gitexecdir="/usr/lib/git-core" \
  NO_TCLTK=1 NO_PYTHON=1 NO_EXPAT=1 NO_GETTEXT=1 NO_LUA=1 \
  NO_REGEX=NeedsStartEnd NO_ICONV=YesPlease NO_SVN_TESTS=YesPlease \
  DESTDIR="$PKG" $jobs V=1 all install || exit

# install additionals lua scripts
install -m 0644 -D $CWD/config/email-libravatar-korg.lua \
  $PKG/usr/share/cgit/filters/email-libravatar-korg.lua
install -m 0644 -D $CWD/config/email-gravatar-sbo.lua \
  $PKG/usr/share/cgit/filters/email-gravatar-sbo.lua

mkdir -p $PKG/usr/doc/$PRGNAM-$VERSION
install -m0644 -oroot $DOCS $PKG/usr/doc/$PRGNAM-$VERSION
sed -i "s|@DOCROOT@|$DOCROOT|g" $PKG/usr/doc/$PRGNAM-$VERSION/*
cat $CWD/$PRGNAM.SlackBuild > $PKG/usr/doc/$PRGNAM-$VERSION/$PRGNAM.SlackBuild

# prepare the cache dir: default permissions are for the apache user and group
mkdir -p $PKG/var/cache/cgit
chown 80.80 $PKG/var/cache/cgit
chmod 775 $PKG/var/cache/cgit

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc

strdoc
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.${PKGTYPE:-tgz}
