#!/bin/sh

### DOESN'T COMPILE IN CHROOT, AFAIK. ###
### Also, the make install doesn't set the executable bit on the 
# privoxy binary, so that's on the TODO list..
. /etc/compiler.vars

PRGNAM=privoxy
VERSION=${VERSION:-3.0.23}
BUILD=${BUILD:-1}
TAG=${TAG:-_SBo}

CWD=$(pwd)
TMP=${TMP:-/tmp/SBo}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

rm -rf $PKG
mkdir -p $TMP $PKG $OUTPUT
cd $TMP
rm -rf $PRGNAM-$VERSION-stable
tar xvf $CWD/$PRGNAM-$VERSION-stable-src.tar.gz
cd $PRGNAM-$VERSION-stable
chown -R root:root .
chmod -R u+w,go-w,a+rX-st .

autoheader
autoconf
CC="$CC -static $mcf $mldf" \
./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --disable-zlib \
  $HOSTDIST

make $jobs 
make install-strip DESTDIR=$PKG

find $PKG/usr/man -type f -exec gzip -9 {} +

mkdir -p $PKG/etc/rc.d
sed \
  -e "s/%PROGRAM%/$PRGNAM/" \
  -e "s,%SBIN_DEST%,/usr/sbin," \
  -e "s,%CONF_DEST%,/etc/$PRGNAM," \
  -e "s/%USER%/$PRIVOXY_USER/" \
  -e "s/%GROUP%/$PRIVOXY_GROUP/" \
  slackware/rc.privoxy.orig \
  > $PKG/etc/rc.d/rc.privoxy.new
chmod +x $PKG/etc/rc.d/rc.privoxy.new

# Make .new files so we don't clobber the existing configuration.
for i in config match-all.action trust user.action user.filter; do
  mv $PKG/etc/privoxy/$i $PKG/etc/privoxy/$i.new
done
# Others are not intended to be user-editable and will be overwritten.
# To disregard, uncomment this and the corresponding lines in doinst.sh.
#find $PKG/etc/privoxy -name '*.new' -prune -o -type f -exec mv {} {}.new \;

# Don't clobber the logfile either.
mv $PKG/var/log/privoxy/logfile $PKG/var/log/privoxy/logfile.new

# Remove empty directories that are part of Slackware base.
rmdir $PKG/usr/share
rmdir $PKG/var/run

strdoc
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD$TAG.${PKGTYPE:-txz}
