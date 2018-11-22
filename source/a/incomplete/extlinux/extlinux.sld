#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

APP=extlinux
VERSION=4.06
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z 
cd $APP-$VERSION
chown -R root:root .

make CC="$CC" -C libinstaller/
make CC="$CC" -C extlinux/
# Notes
# In the syslinux package, we are, for now, only interested in the extlinux
# static executable and the mbr.bin file that we would "dd" later. 
# So, we copy the extlinux binary from the "extlinux" directory to $PKG.
# Also, we copy mbr.bin and gptmbr.bin files to the package for later use. 
mkdir -p $PKG/boot/extlinux
cp $CWD/extlinux.conf $PKG/boot/extlinux/
cp mbr/{mbr,gptmbr}.bin $PKG/boot/extlinux/
mkdir -p $PKG/bin
cp extlinux/extlinux $PKG/bin/

cp extlinux/extlinux $PKG/bin/
mkdir -p $PKG/install

if [ -e $CWD/doinst.sh.gz ]; then
zcat $CWD/doinst.sh.gz > $PKG/install/doinst.sh
fi

cat $CWD/slack-desc > $PKG/install/slack-desc
cd $PKG; str
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH.txz 
