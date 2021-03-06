#!/bin/sh

. /etc/compiler.vars

DOCS=no
PULSEAUDIO=no
PRGNAM=qt5
VERSION=${VERSION:-5.11.2}
BUILD=${BUILD:-1}

CWD=$(pwd)
TMP=${TMP:-/tmp/SBo}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-/tmp}

rm -rf $PKG
mkdir -p $TMP $PKG $OUTPUT
cd $TMP
echo "Removing any existing source directory. Please wait..."
rm -rf ${PRGNAM/5/}-everywhere-src-$VERSION
tar xvf $CWD/${PRGNAM/5/}-everywhere-src-$VERSION.tar.xz
cd ${PRGNAM/5/}-everywhere-src-$VERSION
chown -R root:root .

#patch -p0 < "$CWD"/qt-musl-socklen.patch || exit 1
#patch -p0 < "$CWD"/qt-execinfo.patch || exit 1
#patch -p0 < "$CWD"/qt-musl-mallinfo.patch || exit 1
#patch -p0 < "$CWD"/qt-musl-pthread_getattr_np.patch || exit 1
#patch -p0 < "$CWD"/qt-musl-resolve.patch || exit 1
#patch -p0 < "$CWD"/qt-musl-siginfo_t.patch || exit 1
#patch -p0 < "$CWD"/qt-musl-sys_errno_h.patch || exit 1
#patch -p0 < "$CWD"/qt-pic.patch || exit 1
#patch -p0 < "$CWD"/qt-stdin.patch || exit 1

#export LDFLAGS="-lexecinfo" 
export QMAKE_CXXFLAGS="-D_GNU_SOURCE -fpermissive -lexecinfo" 
export CXXFLAGS="-D_GNU_SOURCE -fpermissive -lexecinfo" 
./configure \
  -confirm-license \
  -opensource \
  -prefix "/usr/lib/$PRGNAM" \
  -sysconfdir "/etc/xdg" \
  -headerdir "/usr/include/$PRGNAM" \
  -libdir "/usr/lib" \
  -docdir "/usr/doc/$PRGNAM-$VERSION" \
  -no-dbus \
  -no-cups \
  -no-pch \
  -no-opengl \
  -no-widgets \
  -system-libpng \
  -system-libjpeg \
  -system-zlib \
  -system-harfbuzz \
  -qt-xcb \
  -openssl-linked \
  -verbose \
  -no-separate-debug-info \
  -no-slog2 \
  -no-icu \
  -no-pch \
  -no-tslib \
  -no-strip \
  -no-eglfs \
  -release \
  -no-pulseaudio \
  -no-libproxy \
  -no-mtdev \
  -no-qml-debug \
  -no-sql-db2 \
  -no-sql-ibase \
  -no-sql-mysql \
  -no-sql-oci \
  -no-sql-odbc \
  -no-sql-psql \
  -no-sql-sqlite \
  -no-sql-sqlite2 \
  -no-sql-tds \
  -no-xkbcommon-evdev \
  -no-libinput \
  -no-compile-examples || exit 1

make $jobs || 
make install INSTALL_ROOT=$PKG || exit 1

# Install documentation. Default is not to install documentation.
#if [ "${DOCS:-no}" == "yes" ]; then
#  # Recreate Makefiles in order to use the just compiled qdoc.
#  for doc in $(find . -name "Makefile*" | xargs egrep "^\s/usr/lib${LIBDIRSUFFIX}/qt5/bin/" \
#    | cut -d':' -f1 | uniq)
#  do
#    rm -fv $doc
#  done
#  make docs
#  make install_docs INSTALL_ROOT=$PKG
#fi

#ln -s $PRGNAM $PKG/usr/lib${LIBDIRSUFFIX}/qt-$VERSION

#mkdir -p $PKG/usr/bin
#for BIN in $PKG/usr/lib${LIBDIRSUFFIX}/$PRGNAM/bin/*; do
#  TMP_FILE=$(echo $BIN | sed -e "s|$PKG||")
#  case $(basename $BIN) in
#    syncqt.pl|fixqt4headers.pl)
#      ln -s $TMP_FILE $PKG/usr/bin/$(basename $BIN)
#      ;;
#    *)
#      ln -s $TMP_FILE $PKG/usr/bin/$(basename $BIN)-$PRGNAM
#      ;;
#  esac
#done

## Create Environment variables
#mkdir -p $PKG/etc/profile.d
#sed -e "s|@LIBDIRSUFFIX@|${LIBDIRSUFFIX}|g" $CWD/profile.d/$PRGNAM.sh \
#  > $PKG/etc/profile.d/$PRGNAM.sh
#sed -e "s|@LIBDIRSUFFIX@|${LIBDIRSUFFIX}|g" $CWD/profile.d/$PRGNAM.csh \
3  > $PKG/etc/profile.d/$PRGNAM.csh
#chmod 0755 $PKG/etc/profile.d/*

cat > $PKG/usr/lib${LIBDIRSUFFIX}/pkgconfig/Qt5.pc << EOF
prefix=/usr/lib${LIBDIRSUFFIX}/$PRGNAM
bindir=\${prefix}/bin
datadir=\${prefix}
docdir=/usr/doc/$PRGNAM-$VERSION
archdatadir=\${prefix}
examplesdir=\${prefix}/examples
headerdir=/usr/include/$PRGNAM
importdir=\${prefix}/imports
qmldir=\${prefix}/qml
libdir=/usr/lib${LIBDIRSUFFIX}
libexec=\${prefix}/libexec
moc=\${bindir}/moc
plugindir=\${prefix}/plugins
qmake=\${bindir}/qmake
sysconfdir=/etc/xdg
translationdir=\${prefix}/translations

Name: Qt5
Description: Qt5 Configuration
Version: $VERSION
EOF

# Fix internal linking for Qt5WebEngineCore.pc.
sed -i \
  -e 's|-Wl,--start-group.* -Wl,--end-group||' \
  -e "s|-L${PWD}/qtwebengine/src/core/api/Release||" \
  $PKG/usr/lib${LIBDIRSUFFIX}/pkgconfig/Qt5WebEngineCore.pc

# While we are at it, there isn't any reason to keep references to $PKG in the *.prl files.
for PRL in $(find $PKG -name "*\.prl"); do
  sed -i '/^QMAKE_PRL_BUILD_DIR/d' $PRL
done

# One more for the road.
sed -i "s|$PWD/qtbase|/usr/lib${LIBDIRSUFFIX}/$PRGNAM|" \
  $PKG/usr/lib${LIBDIRSUFFIX}/$PRGNAM/mkspecs/modules/qt_lib_bootstrap_private.pri

sed -i "s|-L${PWD}/\w*/lib ||g" \
  $PKG/usr/lib${LIBDIRSUFFIX}/libqgsttools_p.prl

for i in $CWD/desktop/*.desktop; do
  install -D -m 0644 $i $PKG/usr/share/applications/$(basename $i)
done
sed -i "s|@LIBDIR@|$LIBDIRSUFFIX|" $PKG/usr/share/applications/*

# Currently not working for qt version 5.4.0.  Extra layer added to *.ico file
# freaks out ImageMagick and fails image conversion.
# Eg.
#   $ convert assistant.ico -resize 96x96! assistant.png
#     convert: file format version mismatch `assistant.ico' @ error/xwd.c/ReadXWDImage/241.
#     convert: no images defined `assistant.png' @ error/convert.c/ConvertImageCommand/3127.
#for i in $(find . -name "assistant.ico" -o -name "designer.ico" \
#  -o -name "linguist.ico" -o -name "qdbusviewer.ico"); do
#  for j in 16 24 32 48 64 96 128; do
#    convert $i -resize ${j}x${j}! $(basename $i)-$j.png
#    install -D -m 0644 $(basename $i)-$j-0.png \
#      $PKG/usr/share/icons/hicolor/${j}x${j}/apps/$(basename $i | sed 's|.ico||')-$PRGNAM.png
#  done
#done

install -D -m 0644 qttools/src/assistant/assistant/images/assistant-128.png \
  $PKG/usr/share/icons/hicolor/128x128/apps/assistant-qt5.png
install -D -m 0644 qttools/src/designer/src/designer/images/designer.png \
  $PKG/usr/share/icons/hicolor/128x128/apps/designer-qt5.png
install -D -m 0644 qttools/src/qdbus/qdbusviewer/images/qdbusviewer-128.png \
  $PKG/usr/share/icons/hicolor/128x128/apps/qdbusviewer-qt5.png
for i in 16 32 48 64 128; do
  install -D -m 0644 qttools/src/linguist/linguist/images/icons/linguist-${i}-32.png \
    $PKG/usr/share/icons/hicolor/${i}x${i}/apps/linguist-qt5.png
done

# Remove executable bits from files.
find $PKG \( -name "*.qml" -o -name "*.app" \) -perm 755 -exec chmod 644 '{}' \;

mkdir -p $PKG/usr/doc/$PRGNAM-$VERSION
cp -a \
  README qtbase/{header*,LGPL_EXCEPTION.txt,LICENSE.*L} \
  $PKG/usr/doc/$PRGNAM-$VERSION
cat $CWD/$PRGNAM.SlackBuild > $PKG/usr/doc/$PRGNAM-$VERSION/$PRGNAM.SlackBuild

mkdir -p $PKG/install
cat $CWD/slack-desc > $PKG/install/slack-desc
cat $CWD/doinst.sh > $PKG/install/doinst.sh

cd $PKG
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$ARCH-$BUILD.txz
