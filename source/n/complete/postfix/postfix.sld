#!/bin/sh

# DO WHATEVER YOU WANT TO PUBLIC LICENSE
# 0. You just DO WHATEVER YOU WANT TO.
#    As simple as that.

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

JOBS="-j2"

APP=postfix
VERSION=3.1.0
PKG=$TMP/package-$APP
BUILD=1sml

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2 -fPIC"
  LIBDIRSUFFIX=""        
else                  
  SLKCFLAGS="-O2"    
  LIBDIRSUFFIX=""              
fi    

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.gz 
cd $APP-$VERSION
chown -R root:root .

AUXLIBS="-L/usr/lib -L/lib -lssl -lcrypto" \
CCARGS="-I/usr/include -I/include -DNO_NIS -DNO_PCRE -DNO_NISPLUS" \
	  make -f Makefile.init makefiles
make $JOBS

sh postfix-install -non-interactive \
	install_root=$PKG \
	daemon_directory=/usr/libexec/postfix \
	manpage_directory=/usr/man \
	command_directory=/usr/sbin \
	config_directory=/etc/postfix || exit

cd $PKG                                  
echo "Stripping binaries and shared objects, if any..."            
 find . | xargs file | grep "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
 find . | xargs file | grep "shared object" | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded 2> /dev/null
                                                   
find $PKG/usr/man -type f -exec gzip -9 {} \;
for i in $( find $PKG/usr/man -type l ) ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done

mkdir $PKG/etc/rc.d
cp $CWD/rc.postfix $PKG/etc/rc.d/rc.postfix.new

cd $PKG
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
