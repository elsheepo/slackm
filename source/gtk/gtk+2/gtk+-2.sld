#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=2
APP=gtk+
VERSION=2.24.31
PKG=$TMP/package-$APP

rm -rf $PKG
mkdir -p $TMP $PKG
rm -rf $TMP/$APP-$VERSION

cd $TMP || exit
tar -xvf $CWD/$APP-$VERSION.tar.?z
cd $APP-$VERSION
chown -R root:root .

patch -p1 < $CWD/gtk-icontheme-fallback.patch

# fixes from LFS: fix messed up makefile when docbook is installed
sed -i 's#l \(gtk-.*\).sgml#& -o \1#' docs/tutorial/Makefile.in
sed -i 's#l \(gtk-.*\).sgml#& -o \1#' docs/faq/Makefile.in
sed -i 's#.*@man_#man_#' docs/reference/gtk/Makefile.in

printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > gdk/tests/Makefile.in
printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > gtk/tests/Makefile.in
printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > tests/Makefile.in
printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > modules/other/gail/tests/Makefile.in
printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue" > docs/reference/gtk/Makefile.in

# remove obfuscated symbols
printf '#!/bin/sh\ntrue\n' > gtk/makegtkalias.pl
for i in gtk/gtkaliasdef.c gtk/gtkalias.h ; do
        rm -f "$i" && touch "$i"
done

./configure \
--prefix=/usr \
--disable-rebuilds \
--disable-glibtest \
--disable-cups \
--disable-introspection \
--enable-xkb 


echo '#include <string.h>' >> config.h

for i in demos tests po po-properties ; do
  printf 'all:\n\ttrue\n\ninstall:\n\ttrue\n\nclean:\n\ttrue\n\ndistclean:\n\ttrue' \
    > "$i"/Makefile
done

make $jobs || exit
make install DESTDIR=$PKG

sed -i 's@gio-2.0@gio-2.0 gmodule-2.0@' "$PKG"/lib/pkgconfig/gtk+-x11-2.0.pc

# Install wrappers for the binaries:
cp -a $CWD/update-gtk-immodules* $PKG/usr/bin
chown root:root $PKG/usr/bin/update-*
chmod 0755 $PKG/usr/bin/update-*

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
