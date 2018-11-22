#!/bin/sh


PKGNAM=glibc-zoneinfo
ZONE_VERSIONS="$(echo tzdata* | cut -f1 -d . | cut -b7-11)"
BUILD=${BUILD:-1}

NUMJOBS=${NUMJOBS:-" -j7 "}

CWD=$(pwd)
TMP=${TMP:-/tmp}
PKG=$TMP/package-$PKGNAM

rm -rf $PKG
mkdir -p $TMP $PKG/etc

# Build and install the zoneinfo database:
cd $TMP
rm -rf tzcodedata-build
mkdir tzcodedata-build
cd tzcodedata-build
tar xzf $CWD/tzdata?????.tar.gz
tar xzf $CWD/tzcode?????.tar.gz

chown -R root:root .

sed -i "s,/usr/local,$(pwd),g" Makefile
sed -i "s,/etc/zoneinfo,/zoneinfo,g" Makefile
make
make install
mkdir -p $PKG/usr/share/zoneinfo
cd etc
cp -a zoneinfo/* $PKG/usr/share/zoneinfo

# These are all identical to the normal zoneinfo files, so let's hard link
# them to save space:
cp -al $PKG/usr/share/zoneinfo $PKG/usr/share/posix
mv $PKG/usr/share/posix $PKG/usr/share/zoneinfo

mkdir -p $PKG/usr/share/zoneinfo/right
cp -a zoneinfo-leaps/* $PKG/usr/share/zoneinfo/right

# Remove $PKG/usr/share/zoneinfo/localtime -- the install script will
# create it as a link to /etc/localtime.
rm -f $PKG/usr/share/zoneinfo/localtime

# Install some scripts to help select a timezone:
mkdir -p $PKG/var/log/setup
cp -a $CWD/timezone-scripts/setup.timeconfig $PKG/var/log/setup
chown root:root $PKG/var/log/setup/setup.timeconfig
chmod 755 $PKG/var/log/setup/setup.timeconfig
mkdir -p $PKG/usr/sbin
cp -a $CWD/timezone-scripts/timeconfig $PKG/usr/sbin
chown root:root $PKG/usr/sbin/timeconfig
chmod 755 $PKG/usr/sbin/timeconfig
( cd $CWD/timezone-scripts
  # Try to rebuild this:
  sh output-updated-timeconfig.sh $PKG/usr/share/zoneinfo > $PKG/usr/sbin/timeconfig 2> /dev/null
)
# Note in timeconfig which zoneinfo database was used:
sed -i "s/# ChangeLog:/# ChangeLog:\n# $(date '+%Y-%m-%d'):   Updated timezones from tzdata${ZONE_VERSIONS}./g" $PKG/usr/sbin/timeconfig

# Don't forget to add the /usr/share/zoneinfo/localtime -> /etc/localtime symlink! :)
if [ ! -r $PKG/usr/share/zoneinfo/localtime ]; then
  ( cd $PKG/usr/share/zoneinfo ; ln -sf /etc/localtime . )
fi

cd ..
mkdir -p $PKG/usr/doc/zoneinfo-$ZONE_VERSIONS
cp -a \
  CONTRIBUTING NEWS README Theory \
  $PKG/usr/doc/glibc-zoneinfo-$ZONE_VERSIONS

mkdir -p $PKG/install
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
cat $CWD/slack-desc > $PKG/install/slack-desc

cd $PKG
makepkg -l y -c n $TMP/zoneinfo-$ZONE_VERSIONS-noarch-$BUILD.txz
