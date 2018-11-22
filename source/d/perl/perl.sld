#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=perl
VERSION=5.24.3
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

sed '1i#define PERL_BUILD_DATE "01.01.18 00:00:00"' -i perl.c

sed -e 's;myuname=`$u;myuname="linux host" #`$u;' \
    -e 's;cf_time=`;cf_time="01.01.18 00:00:00" #`;' \
    -e 's;cf_by=`;cf_by=user #`;' \
    -e "s;^myhostname='';myhostname=host;" \
    -e "s;^phostname='';phostname=host;" \
-i Configure

sed -i 's,-fstack-protector,-fnostack-protector,g' ./Configure

CC="$CC" \
CFLAGS="$mcf $mldf" \
LDFLAGS="$mldf -ldb" \
./Configure -de \
  -Dprefix=/usr \
  -Dsiteprefix=/usr/local \
  -Dsitelib="/usr/share/perl5" \
  -Dsitearch="/usr/local/lib/perl5" \
  -Darchlib="/usr/lib/perl5" \
  -Dvendorprefix=/usr \
  -Dprivlib="/usr/share/perl5" \
  -Dvendorlib="/usr/share/perl5/vendor_perl" \
  -Dvendorarch="/usr/lib/perl5/vendor_perl" \
  -Dscriptdir='/usr/bin' \
  -Dcccdlflags='-fPIC' \
  -Dinstallprefix=/usr \
  -Dlibpth="/usr/local/lib /usr/lib /lib" \
  -Doptimize="$mcf -L/usr/lib -L/lib" \
  -Duseshrplib \
  -Ubincompat5005 \
  -Uversiononly 

make $jobs || exit
make test
make install DESTDIR=$PKG

mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

if [ -e $CWD/slack-desc ]; then
cat $CWD/slack-desc > $PKG/install/slack-desc
fi

rm -rf "$PKG"/share/man
rm -rfv "$PKG"/*.0
# Strip binaries
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
