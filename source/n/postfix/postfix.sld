#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=postfix
VERSION=3.1.0
PKG=$TMP/package-$APP
BUILD=2

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz 
cd $APP-$VERSION
chown -R root:root .

AUXLIBS="-L/usr/lib -L/lib -lssl -lcrypto" \
CCARGS="-I/usr/include -I/include -DNO_NIS -DNO_PCRE -DNO_NISPLUS" \
	  make -f Makefile.init makefiles
make $jobs

sh postfix-install -non-interactive \
	install_root=$PKG \
	daemon_directory=/usr/libexec/postfix \
	manpage_directory=/usr/man \
	command_directory=/usr/sbin \
	config_directory=/etc/postfix || exit

mkdir $PKG/etc/rc.d
cp $CWD/rc.postfix $PKG/etc/rc.d/rc.postfix.new

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
