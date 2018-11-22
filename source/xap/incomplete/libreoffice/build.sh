#!/bin/sh
./configure \
--prefix=/usr \
--libdir=/usr/lib \
--mandir=/usr/man \
--sysconfdir=/etc \
--enable-debug \
--enable-python=no \
--disable-gtk3 \
--disable-qt5 \
--disable-kde5 \
--disable-gtk3-kde5 \
--disable-cups \
--without-java \
--without-doxygen \
--without-lxml \
--with-locals="en" \
--without-krb5 \
--without-gssapi \
--without-iwyu
