#!/bin/sh
./configure \
--disable-xpcom \
--disable-python \
--disable-java \
--disable-vmmraw \
--disable-sdl-ttf \
--disable-alsa \
--disable-dbus \
--disable-kmods \
--disable-opengl \
--disable-webservice \
--enable-vnc \
--disable-docs \
--disable-libvpx \
--disable-vde \
--disable-hardening \
--build-headless
