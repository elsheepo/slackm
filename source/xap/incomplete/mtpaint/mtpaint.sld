#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=mtpaint
VERSION=3.40
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z?
cd $APP-$VERSION
chown -R root:root .

# bring deprecated function call into conformance with libpng14
sed -i 's/png_set_gray_1_2_4_to_8/png_set_expand_gray_1_2_4_to_8/' src/png.c

# Fix build with giflib-5.1 (thanks to Arch)
sed -i 's:EGifOpenFileName(file_name, FALSE):EGifOpenFileName(file_name, FALSE, NULL):' src/png.c
sed -i 's:DGifOpenFileName(file_name):DGifOpenFileName(file_name, NULL):g' src/png.c
sed -i 's:EGifCloseFile(giffy):EGifCloseFile(giffy, NULL):g' src/png.c
sed -i 's:DGifCloseFile(giffy):DGifCloseFile(giffy, NULL):g' src/png.c
sed -i 's:MakeMapObject(:GifMakeMapObject(:g' src/png.c
sed -i 's:FreeMapObject(:GifFreeMapObject(:g' src/png.c

./configure cflags man \
--prefix=/usr \
--mandir=/usr/man

make $jobs || exit
make install DESTDIR=$PKG

find $PKG/usr/man -type f -exec gzip -9 {} \;
for i in $( find $PKG/usr/man -type l ) ; do ln -s $( readlink $i ).gz $i.gz ; rm $i ; done

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
