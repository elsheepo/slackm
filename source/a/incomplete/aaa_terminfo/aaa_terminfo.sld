#!/bin/sh
# Copyright 2006, 2007, 2009, 2010, 2011  Patrick J. Volkerding, Sebeka, MN, USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

. /etc/compiler.vars

PKGNAM=aaa_terminfo
# Note the version of ncurses in use:
VERSION=${VERSION:-5.8}
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-${PKGNAM}
rm -rf $PKG
mkdir -p $TMP $PKG

# Best do this on a machine with the terminfo
# updated already.  ;-)
cd $PKG

# I wonder if anything still looks here?
mkdir -p usr/lib${LIBDIRSUFFIX}
( cd usr/lib${LIBDIRSUFFIX}
  rm -rf terminfo
  ln -sf /usr/share/terminfo terminfo
)

# This has been the tradition starter collection since forever.
for dir in l n u v x ; do
  mkdir -p usr/share/terminfo/$dir
  ( cd usr/share/terminfo/$dir
    cp -a /usr/share/terminfo/$dir/* .
  )
done

# Remove dangling symlinks:
( cd usr/share/terminfo
  for file in $(find . -type l) ; do
    if [ "$(readlink -e $file)" = "" ]; then
      rm --verbose $file
    fi
  done
)

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc

cd $TMP/package-${PKGNAM}
/sbin/makepkg -l y -c n $TMP/${PKGNAM}-$VERSION-$ARCH-$BUILD.txz

