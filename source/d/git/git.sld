#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=git
VERSION=2.15.1
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

make \
  prefix="/usr" gitexecdir="/usr/lib/git-core" \
  NO_TCLTK=1 NO_PYTHON=1 NO_EXPAT=1 NO_GETTEXT=1 \
  NO_REGEX=NeedsStartEnd \
  DESTDIR="$PKG" $jobs V=1 all install || exit

mkdir -p "$PKG"/bin
cp gitk-git/gitk "$PKG"/bin/
ln -sf git "$PKG"/bin/git-receive-pack
ln -sf git "$PKG"/bin/git-upload-archive

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
