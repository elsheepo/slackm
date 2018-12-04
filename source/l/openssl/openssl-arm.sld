#!/bin/sh

# The compiler stalls because it requires perl.
# The compilation is being done in a chroot, and I didn't have perl 
# installed in chroot. So I built it outside the chroot where perl would 
# be available. 

#. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=openssl
VERSION=1.0.2p
PKG=$TMP/package-$APP
BUILD=1

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz
cd $APP-$VERSION
chown -R root:root .

# I've had to specifically build openssl to compile the ZNC IRC bouncer. 
# The IRC bouncer fails to build with libressl. 

# If you cross compile openssl, it will by default run host ld/ar/ranlib 
# commands even if CC is set, and for some odd reason, you can't supply 
# it with --host option, so here I've set all the four programs manually.
	./Configure \
	--prefix=/usr \
	--openssldir=/etc/ssl \
	no-rc5 \
	shared \
	linux-armv4 

# Openssl doesn't like parallel make jobs :-(	
make 
make install INSTALL_PREFIX=$PKG || exit

# Add a cron script to warn root if a certificate is going to expire soon
mkdir -p $PKG/etc/cron.daily
zcat $CWD/certwatch.gz > $PKG/etc/cron.daily/certwatch.new
chmod 755 $PKG/etc/cron.daily/certwatch.new

mv $PKG/etc/ssl/openssl.cnf $PKG/etc/ssl/openssl.cnf.new

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
