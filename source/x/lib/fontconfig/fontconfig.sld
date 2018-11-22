#!/bin/bash

. /etc/compiler.vars

cd $(dirname $0) ; CWD=$(pwd)

PKGNAM=fontconfig
VERSION=${VERSION:-$(echo fontconfig-*.tar.?z* | rev | cut -f 3- -d . | cut -f 1 -d - | rev)}
BUILD=${BUILD:-1}


# If the variable PRINT_PACKAGE_NAME is set, then this script will report what
# the name of the created package would be, and then exit. This information
# could be useful to other scripts.
if [ ! -z "${PRINT_PACKAGE_NAME}" ]; then
  echo "$PKGNAM-$VERSION-$ARCH-$BUILD.txz"
  exit 0
fi

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}

TMP=${TMP:-/tmp}
PKG=$TMP/package-fontconfig

rm -rf $PKG
mkdir -p $TMP $PKG

cd $TMP
rm -rf fontconfig-$VERSION
tar xvf $CWD/fontconfig-$VERSION.tar.?z* || exit 1
cd fontconfig-$VERSION || exit 1
chown -R root:root .

# Prefer DejaVu fonts in 60-latin.conf:
#zcat $CWD/fontconfig.dejavu.diff.gz | patch -p1 --verbose || exit 1

# Prefer Liberation fonts in 60-latin.conf (these work better with hinting):
zcat $CWD/fontconfig.liberation.diff.gz | patch -p1 --verbose || exit 1

# Hardcode the default font search path rather than having fontconfig figure
# it out (and possibly follow symlinks, or index ugly bitmapped fonts):
zcat $CWD/fontconfig.font.dir.list.diff.gz | patch -p1 --verbose --backup --suffix=.orig || exit 1

CFLAGS=$SLKCFLAGS \
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --mandir=/usr/man \
  --sysconfdir=/etc \
  --with-templatedir=/etc/fonts/conf.avail \
  --with-baseconfigdir=/etc/fonts \
  --with-configdir=/etc/fonts/conf.d \
  --with-xmldir=/etc/fonts \
  --localstatedir=/var \
  --enable-static=no \
  --build=$ARCH-slackware-linux || exit 1

make $NUMJOBS || make || exit 1
make install DESTDIR=$PKG || exit 1

# Don't ship .la files:
rm -f $PKG/{,usr/}lib${LIBDIRSUFFIX}/*.la

# Upstream has changed the default templatedir to /usr/share/fontconfig/conf.avail.
# This change, if accepted, would break any existing font package containing a
# conf.avail directory.  The safest thing to do is to keep things in the
# traditional location, but put a link in the new place so that font packages
# following the new standard location will work.  Let's hear it for being
# "more correct" at the expense of having things "just work"!
mkdir -p $PKG/usr/share/fontconfig
( cd $PKG/usr/share/fontconfig ; ln -sf /etc/fonts/conf.avail . )

mkdir -p $PKG/usr/doc/fontconfig-$VERSION
cp -a \
  AUTHORS COPYING* INSTALL NEWS README \
  $PKG/usr/doc/fontconfig-$VERSION
# You can shop for this kind of stuff in the source tarball.
rm -rf $PKG/usr/share/doc
rmdir $PKG/usr/share 2>/dev/null

# If there's a ChangeLog, installing at least part of the recent history
# is useful, but don't let it get totally out of control:
if [ -r ChangeLog ]; then
  DOCSDIR=$(echo $PKG/usr/doc/*-$VERSION)
  cat ChangeLog | head -n 1000 > $DOCSDIR/ChangeLog
  touch -r ChangeLog $DOCSDIR/ChangeLog
fi

mkdir -p $PKG/var/log/setup
cat $CWD/setup.05.fontconfig > $PKG/var/log/setup/setup.05.fontconfig
chmod 755 $PKG/var/log/setup/setup.05.fontconfig

find $PKG | xargs file | grep -e "executable" -e "shared object" | grep ELF \
  | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null

# Set up the default options in /etc/fonts/conf.d:
(  cd $PKG/etc/fonts/conf.d
   for fontconf in \
        20-unhint-small-vera.conf \
        30-metric-aliases.conf \
        40-nonlatin.conf \
        45-latin.conf \
        49-sansserif.conf \
        50-user.conf \
        51-local.conf \
        60-latin.conf \
        65-fonts-persian.conf \
        65-nonlatin.conf \
        69-unifont.conf \
        80-delicious.conf \
        90-synthetic.conf ; do
     if [ -r ../conf.avail/$fontconf ]; then
       ln -sf ../conf.avail/$fontconf .
     else
       echo "ERROR:  unable to symlink ../conf.avail/$fontconf, file does not exist."
       exit 1
     fi
   done
   if [ ! $? = 0 ]; then
     exit 1
   fi
)
if [ ! $? = 0 ]; then
  echo "Missing /etc/fonts/$fontconf default.  Exiting"
  exit 1
fi

# This is a really ugly default.  If you like it, you'll have to link this
# one yourself:
rm -f $PKG/etc/fonts/conf.d/10-hinting-slight.conf

# Fix manpages:
if [ -d $PKG/usr/man ]; then
  ( cd $PKG/usr/man
    for manpagedir in $(find . -type d -name "man*") ; do
      ( cd $manpagedir
        for eachpage in $( find . -type l -maxdepth 1) ; do
          ln -s $( readlink $eachpage ).gz $eachpage.gz
          rm $eachpage
        done
        gzip -9 *.?
      )
    done
  )
fi

mkdir $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh

cd $PKG
/sbin/makepkg -l y -c n --prepend $TMP/fontconfig-$VERSION-$ARCH-$BUILD.txz

