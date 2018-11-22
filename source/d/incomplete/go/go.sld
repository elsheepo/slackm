#!/bin/sh

. /etc/compiler.vars

CWD=$(pwd)
if [ "$TMP" = "" ]; then
  TMP=/tmp
fi

BUILD=1
APP=go
VERSION=1.4.3.src

rm -rf $TMP/go
cd $TMP
tar -xvf $CWD/$APP$VERSION.tar.?z || exit
cd go
echo $PWD
chown -R root:root .

#patch -p1 < $CWD/set-external-linker.patch || exit
#patch -p1 < $CWD/default-buildmode-pie.patch || exit

export GOARCH="amd64"
export GOOS="linux"
#export GOPATH="$srcdir"
export GOROOT="$PKG"
export GOBIN="$GOROOT"/bin
export GOROOT_FINAL=/usr/lib/go

cd src; ./make.bash || exit 

strdoc
/sbin/makepkg -l y -c n $TMP/$APP-$VERSION-$ARCH-$BUILD.txz 
