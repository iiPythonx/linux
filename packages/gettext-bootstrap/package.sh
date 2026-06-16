#!/usr/bin/env bash

build() {
    ./configure --disable-shared
    make
}

install() {
    mkdir -p $LX_ROOTFS/usr/bin
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} $LX_ROOTFS/usr/bin
}

"$LX_STAGE"
